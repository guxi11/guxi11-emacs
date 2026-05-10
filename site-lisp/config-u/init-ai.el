;;; init-ai.el --- Shell configuration using use-package

;;; Commentary:
;; Configuration for vterm and other shell related packages.

;;; Code:

;;;; claude-code :
;; install required inheritenv dependency:
(use-package inheritenv
  :vc (:url "https://github.com/purcell/inheritenv" :rev :newest))

;; for vterm terminal backend:
(use-package vterm :ensure t)

(use-package monet
  :vc (:url "https://github.com/stevemolitor/monet" :rev :newest))

;; ;; install claude-code.el
(use-package claude-code :ensure t
  :vc (:url "https://github.com/stevemolitor/claude-code.el" :rev :newest)
  :config
  ;; optional IDE integration with Monet
  (add-hook 'claude-code-process-environment-functions #'monet-start-server-function)
  (monet-mode 1)

  (claude-code-mode)
  :bind-keymap ("C-c c" . claude-code-command-map)

;;   ;; Optionally define a repeat map so that "M" will cycle thru Claude auto-accept/plan/confirm modes after invoking claude-code-cycle-mode / C-c M.
  :bind
  (:repeat-map my-claude-code-map ("M" . claude-code-cycle-mode)))

(setq claude-code-terminal-backend 'vterm)

;; tmux-backed persistence (independent module under site-lisp/extensions).
;; Per-machine values (claude binary path, etc.) live in <repo-root>/.env;
;; see .env.example for the template.  Falls back to defaults if absent.
(require 'claude-tmux-persist)
(setq claude-tmux-persist-env-file
      (expand-file-name
       "../../.env"
       (file-name-directory (or load-file-name buffer-file-name))))
(setq claude-tmux-persist-restore-on-startup t)
(claude-tmux-persist-mode 1)

(add-to-list 'display-buffer-alist
                 '("^\\*claude"
                   (display-buffer-in-side-window)
                   (side . right)
                   (window-width . 90)))


;; Control the delay before processing buffered vterm output (default is 0.01)
;; This is the time in seconds that vterm waits to collect output bursts
;; A longer delay may reduce flickering more but could feel less responsive
;; The default of 0.01 seconds (10ms) provides a good balance
(setq claude-code-vterm-multiline-delay 0.01)

(defun my-claude-notify (title message)
  "Display a macOS notification with sound."
  (call-process "osascript" nil nil nil
                "-e" (format "display notification \"%s\" with title \"%s\" sound name \"Glass\""
                             message title)))

(setq claude-code-notification-function #'my-claude-notify)

(provide 'init-ai)
;;; init-ai.el ends here
