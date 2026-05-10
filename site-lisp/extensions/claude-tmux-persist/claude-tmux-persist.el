;;; claude-tmux-persist.el --- Persist claude-code instances via tmux  -*- lexical-binding: t; -*-

;;; Commentary:
;; Independent module that makes claude-code.el conversations survive Emacs
;; restarts by routing the claude binary through a per-buffer tmux session.
;; Toggle via `claude-tmux-persist-mode'.
;;
;; Architecture:
;;   Emacs vterm  →  claude-tmux (bash wrapper)  →  exec tmux client
;;                                                     ↕ socket (-L claude-emacs)
;;                                                    tmux server (daemon)
;;                                                     └── session "<name>"
;;                                                           └── pane: claude
;;
;; The vterm child is the tmux CLIENT, not the server.  Killing the Emacs
;; buffer / closing the window only detaches the client; the server and the
;; claude process inside it keep running.  Reopen M-x claude-code in the same
;; project and the wrapper reattaches to the existing session.
;;
;; Per-machine config:
;;   Copy <repo-root>/.env.example to <repo-root>/.env and set CLAUDE_TMUX_BIN.
;;   `.env' is gitignored; see `claude-tmux-persist-env-file'.
;;
;; Terminal commands:
;;   List sessions   : tmux -L claude-emacs ls
;;   Attach manually : tmux -L claude-emacs attach -t <session>
;;   Kill one session: tmux -L claude-emacs kill-session -t <session>
;;   Kill all        : tmux -L claude-emacs kill-server
;;
;;   Or from Emacs   : M-x claude-tmux-persist-list
;;                     M-x claude-tmux-persist-kill
;;                     M-x claude-tmux-persist-kill-server
;;
;; Restore after Emacs restart:
;;   The wrapper logs session → (buffer-name, cwd) to a registry file each
;;   time it runs.  After restarting Emacs, call:
;;     M-x claude-tmux-persist-restore
;;   to reattach vterm buffers to all still-alive tmux sessions.
;;   Set `claude-tmux-persist-restore-on-startup' to t for automatic restore.

;;; Code:

(defgroup claude-tmux-persist nil
  "Persist claude-code conversations via tmux."
  :group 'tools
  :prefix "claude-tmux-persist-")

(defcustom claude-tmux-persist-binary "claude"
  "Underlying claude-compatible binary to wrap."
  :type 'string
  :group 'claude-tmux-persist)

(defcustom claude-tmux-persist-socket "claude-emacs"
  "tmux -L socket name (isolated from the user's interactive tmux)."
  :type 'string
  :group 'claude-tmux-persist)

(defcustom claude-tmux-persist-registry-file "/tmp/claude-tmux-persist.registry"
  "File logging session → (buffer-name, cwd); used by restore.
Lives in /tmp to match the tmux server lifetime (both cleared on reboot)."
  :type 'file
  :group 'claude-tmux-persist)

(defcustom claude-tmux-persist-restore-on-startup nil
  "When non-nil, call `claude-tmux-persist-restore' automatically on startup."
  :type 'boolean
  :group 'claude-tmux-persist)

(defcustom claude-tmux-persist-env-file nil
  "Optional `.env'-style file applied when the mode is enabled.
Recognized keys: `CLAUDE_TMUX_BIN', `CLAUDE_TMUX_SOCKET'.
Any other `KEY=VALUE' line is exported via `setenv' verbatim."
  :type '(choice (const :tag "None" nil) file)
  :group 'claude-tmux-persist)

(defconst claude-tmux-persist--dir
  (file-name-directory (or load-file-name buffer-file-name)))

(defconst claude-tmux-persist--wrapper
  (expand-file-name "claude-tmux" claude-tmux-persist--dir))

(defvar claude-tmux-persist--saved-program nil
  "Original `claude-code-program' before the mode was enabled.")

(defvar claude-code-program)  ; forward decl; bound by claude-code.el
(defvar vterm-shell)          ; forward decl; dynamic var in vterm.el
(declare-function vterm-mode "vterm")

(defun claude-tmux-persist--parse-env-line (line)
  "Parse `KEY=VALUE' from LINE; return (KEY . VALUE) or nil for blank/comment."
  (when (string-match
         "\\`\\s-*\\([A-Za-z_][A-Za-z0-9_]*\\)\\s-*=\\s-*\\(.*?\\)\\s-*\\'"
         line)
    (cons (match-string 1 line)
          (replace-regexp-in-string "\\`['\"]\\(.*\\)['\"]\\'" "\\1"
                                    (match-string 2 line)))))

(defun claude-tmux-persist--read-env-file (file)
  "Return alist parsed from .env-style FILE, or nil if unreadable."
  (and (file-readable-p file)
       (with-temp-buffer
         (insert-file-contents file)
         (seq-keep #'claude-tmux-persist--parse-env-line
                   (split-string (buffer-string) "\n")))))

(defun claude-tmux-persist--apply-env-file ()
  "Apply `claude-tmux-persist-env-file' to env + recognized custom vars."
  (when claude-tmux-persist-env-file
    (dolist (kv (claude-tmux-persist--read-env-file
                 (expand-file-name claude-tmux-persist-env-file)))
      (let ((k (car kv)) (v (cdr kv)))
        (setenv k v)
        (pcase k
          ("CLAUDE_TMUX_BIN"    (setq claude-tmux-persist-binary v))
          ("CLAUDE_TMUX_SOCKET" (setq claude-tmux-persist-socket v)))))))

(defun claude-tmux-persist--read-registry ()
  "Return hash table mapping session-name → (buffer-name . cwd) from registry.
Append-only file: later entries for the same session win (last-write-wins)."
  (let ((tbl (make-hash-table :test #'equal)))
    (when (file-readable-p claude-tmux-persist-registry-file)
      (with-temp-buffer
        (insert-file-contents claude-tmux-persist-registry-file)
        (dolist (line (split-string (buffer-string) "\n" t))
          (let ((parts (split-string line "\t")))
            (when (>= (length parts) 3)
              (puthash (nth 0 parts)
                       (cons (nth 1 parts) (nth 2 parts))
                       tbl))))))
    tbl))

;;;###autoload
(defun claude-tmux-persist-restore ()
  "Reattach vterm buffers to all live claude-tmux sessions.
Reads the registry written by the claude-tmux wrapper.  Safe to call multiple
times: skips sessions whose buffer already has a live process."
  (interactive)
  (require 'vterm)
  (let* ((live (claude-tmux-persist--list-sessions))
         (registry (claude-tmux-persist--read-registry))
         (restored 0))
    (dolist (session live)
      (let* ((entry (gethash session registry))
             (buf-name (if (and entry (not (string-empty-p (car entry))))
                           (car entry)
                         (format "*claude-tmux:%s*" session)))
             (cwd (if (and entry (file-directory-p (cdr entry)))
                      (cdr entry) "~"))
             (buf (get-buffer buf-name))
             (proc (and buf (get-buffer-process buf))))
        (unless (and proc (process-live-p proc))
          (let* ((buf (get-buffer-create buf-name))
                 (attach-cmd (format "tmux -L %s attach-session -t %s"
                                     (shell-quote-argument claude-tmux-persist-socket)
                                     (shell-quote-argument session))))
            (with-current-buffer buf
              (when (and proc (not (process-live-p proc)))
                (delete-process proc)))
            ;; vterm requires a window to initialize correctly (determines
            ;; terminal width); mirror the pop-to-buffer / delete-window
            ;; pattern used by claude-code--term-make for vterm.
            (save-window-excursion
              (pop-to-buffer buf)
              (with-current-buffer buf
                (let ((default-directory cwd)
                      (vterm-shell attach-cmd))
                  (vterm-mode)))))
          (cl-incf restored))))
    (if (zerop restored)
        (message "claude-tmux-persist: nothing new to restore")
      (message "claude-tmux-persist: restored %d session(s)" restored))))

(defun claude-tmux-persist--tmux-cmd (&rest args)
  "Run tmux on the dedicated socket with ARGS; return exit code."
  (apply #'call-process "tmux" nil nil nil
         "-L" claude-tmux-persist-socket args))

(defun claude-tmux-persist--list-sessions ()
  "Return a list of session names on the dedicated tmux server."
  (with-temp-buffer
    (when (zerop (call-process "tmux" nil t nil
                               "-L" claude-tmux-persist-socket
                               "list-sessions" "-F" "#S"))
      (split-string (buffer-string) "\n" t))))

;;;###autoload
(defun claude-tmux-persist-list ()
  "Echo live tmux sessions on the dedicated server."
  (interactive)
  (let ((sessions (claude-tmux-persist--list-sessions)))
    (message (if sessions
                 (format "claude-tmux sessions: %s"
                         (mapconcat #'identity sessions ", "))
               "no live claude-tmux sessions"))))

;;;###autoload
(defun claude-tmux-persist-kill (session)
  "Kill SESSION on the dedicated tmux server."
  (interactive
   (list (completing-read "Kill session: "
                          (claude-tmux-persist--list-sessions) nil t)))
  (claude-tmux-persist--tmux-cmd "kill-session" "-t" session)
  (message "killed claude-tmux session: %s" session))

;;;###autoload
(defun claude-tmux-persist-show-log ()
  "Open the wrapper diagnostic log."
  (interactive)
  (find-file-other-window "/tmp/claude-tmux-persist.log"))

;;;###autoload
(defun claude-tmux-persist-kill-server ()
  "Kill the entire dedicated tmux server (all persisted sessions)."
  (interactive)
  (when (yes-or-no-p "kill ALL claude-tmux sessions? ")
    (claude-tmux-persist--tmux-cmd "kill-server")
    (message "claude-tmux server killed")))

;;;###autoload
(define-minor-mode claude-tmux-persist-mode
  "Route `claude-code' through a per-buffer tmux session for persistence.
When enabled, sets `claude-code-program' to the bundled wrapper and exports
`CLAUDE_TMUX_BIN' / `CLAUDE_TMUX_SOCKET'.  Restored on disable."
  :global t
  :group 'claude-tmux-persist
  (if claude-tmux-persist-mode
      (progn
        (unless (executable-find "tmux")
          (user-error "tmux not found on PATH"))
        (unless (file-executable-p claude-tmux-persist--wrapper)
          (user-error "wrapper not executable: %s" claude-tmux-persist--wrapper))
        (claude-tmux-persist--apply-env-file)
        (setenv "CLAUDE_TMUX_BIN"    claude-tmux-persist-binary)
        (setenv "CLAUDE_TMUX_SOCKET" claude-tmux-persist-socket)
        (setq claude-tmux-persist--saved-program
              (and (boundp 'claude-code-program) claude-code-program))
        (with-eval-after-load 'claude-code
          (setq claude-code-program claude-tmux-persist--wrapper))
        (when claude-tmux-persist-restore-on-startup
          (if after-init-time
              (claude-tmux-persist-restore)
            (add-hook 'after-init-hook #'claude-tmux-persist-restore))))
    (setenv "CLAUDE_TMUX_BIN" nil)
    (setenv "CLAUDE_TMUX_SOCKET" nil)
    (when (and claude-tmux-persist--saved-program
               (boundp 'claude-code-program))
      (setq claude-code-program claude-tmux-persist--saved-program))))

(provide 'claude-tmux-persist)
;;; claude-tmux-persist.el ends here
