;;; init-mode-line --- Summary

;;; Commentary:

;;; Code:

(line-number-mode 1)
(column-number-mode 1)

(defun replace-lambda-with-lambda-sign (start end)
  "Replace all occurrences of the string \"lambda\" with the character λ.
If called with no active region, operate on the entire buffer.
If called with an active region, operate only on the region."
  (interactive
   (if (use-region-p)
       (list (region-beginning) (region-end))
     (list (point-min) (point-max))))
  (save-excursion
    (goto-char start)
    (while (search-forward "lambda" end t)
      (replace-match "λ" nil t))))


(defun greet ()
  (interactive)
  (message "Hello World!"))

;; -----------------------------------------------------------------------------
;; Mode Line Configuration
;; -----------------------------------------------------------------------------

;; 1. Faces Definitions
;; Use :box attribute to add padding
(defgroup my-mode-line nil
  "Custom mode line faces."
  :group 'mode-line)

(defface my-mode-line-buffer-id
  '((t :foreground "VioletRed1" :weight bold)) ; Keep your preferred pink accent
  "Face for buffer identification."
  :group 'my-mode-line)

(defface my-mode-line-git-branch
  '((t :foreground "#98c379" :weight bold)) ; Green for git branch
  "Face for git branch."
  :group 'my-mode-line)

(defface my-mode-line-major-mode
  '((t :foreground "#e5c07b" :weight bold)) ; Gold for major mode
  "Face for major mode."
  :group 'my-mode-line)

(defface my-mode-line-warning
  '((t :foreground "#e06c75" :weight bold)) ; Red for warnings
  "Face for warnings."
  :group 'my-mode-line)

;; Set base mode-line faces (Dark theme optimized)
;; The :box attribute adds the vertical padding you requested
;; NOTE: :box only works in GUI Emacs, not in terminal mode!
;; We define a function to set these to ensure they are applied even if a theme is loaded later
(defun my/set-mode-line-faces ()
  "Set mode-line faces with padding and specific colors.
This function forcefully overrides any theme settings."
  (interactive)
  ;; :box only works in GUI mode
  (let* ((use-box (display-graphic-p))
         ;; Active: Warm earthy brown (coordinated with init-theme fire+earth palette)
         (active-bg "#3d2b1f")  ; Dark earth brown
         (inactive-bg "#131110") ; Blacker (darker than main background)
         (active-box (when use-box `(:line-width (6 . 4) :color ,active-bg :style flat-button)))
         (inactive-box (when use-box `(:line-width (6 . 4) :color ,inactive-bg :style flat-button))))
    
    ;; Active Mode Line: Use `custom-set-faces` for higher priority over themes
    (custom-set-faces
     `(mode-line ((t (:background ,active-bg
                      :foreground "#bbc2cf"
                      :box ,active-box
                      :overline nil
                      :underline nil))))
     `(mode-line-inactive ((t (:background ,inactive-bg
                               :foreground "#5c6370"
                               :box ,inactive-box
                               :overline nil
                               :underline nil))))
     ;; Emacs 29+ mode-line-active takes precedence over mode-line
     `(mode-line-active ((t (:background ,active-bg
                             :foreground "#bbc2cf"
                             :box ,active-box
                             :overline nil
                             :underline nil
                             :inherit nil))))))
  (message "Mode-line faces applied (GUI: %s)." (if (display-graphic-p) "yes" "no")))

;; Don't apply here - will be overridden by init-theme.el which loads later
;; Instead, we apply after init completes (see end of file)

;; 2. Helper Functions

(defun my/shorten-directory (dir max-length)
  "Show up to `max-length' characters of a directory name `dir'."
  (let ((path (reverse (split-string (abbreviate-file-name dir) "/")))
        (output ""))
    (when (and path (equal "" (car path)))
      (setq path (cdr path)))
    (while (and path (< (length output) (- max-length 4)))
      (setq output (concat (car path) "/" output))
      (setq path (cdr path)))
    (when path
      (setq output (concat "..." output)))
    output))

(defun my/get-buffer-path ()
  "Get the buffer path to display.
If the buffer is visiting a file, return the abbreviated file path with directory shortened.
If the file is in a git repository, hide the path before the repository root.
Otherwise, return the buffer name."
  (if buffer-file-name
      (let* ((file-path (file-truename buffer-file-name))
             (git-root (locate-dominating-file file-path ".git"))
             (file-name (file-name-nondirectory buffer-file-name))
             (dir-name (file-name-directory file-path)))
        (if git-root
            (let* ((git-root (file-truename git-root))
                   (root-parent (file-name-directory (directory-file-name git-root)))
                   (rel-dir (file-relative-name dir-name root-parent))
                   (short-dir (my/shorten-directory rel-dir 40)))
              (concat short-dir file-name))
          (let ((short-dir (if dir-name (my/shorten-directory dir-name 30) "")))
            (concat short-dir file-name))))
    "%b"))

(defun my/get-git-branch ()
  "Get the current git branch name with an icon."
  (let ((branch (and (boundp 'vc-mode) vc-mode)))
    (if branch
        (let ((name (substring-no-properties branch 5)))
          ;; Using Powerline symbol . If it doesn't display, you can change it to "Git:"
          (format "  %s " name))
      "")))

(defun my/mode-line-fill (face reserve)
  "Return empty space using FACE and leaving RESERVE space on the right."
  (unless reserve (setq reserve 20))
  (when (and window-system (eq 'right (get-scroll-bar-mode)))
    (setq reserve (- reserve 3)))
  (propertize " "
              'display `((space :align-to (- (+ right right-fringe right-margin) ,reserve)))
              'face face))

;; 3. Mode Line Format Composition

(setq-default mode-line-format
  (list
   ;; Status Indicator: Diamond(ReadOnly), Yellow Dot(Modified), Green Dot(Normal)
   '(:eval (cond (buffer-read-only
                  (propertize " ◆ " 'face 'my-mode-line-warning))  ; Solid diamond
                 ((buffer-modified-p)
                  (propertize " ● " 'face '(:foreground "#e5c07b")))
                 (t
                  (propertize " ● " 'face '(:foreground "#98c379")))))

   ;; Buffer Name (Highlighted in Pink when active)
   '(:eval (propertize (concat " " (my/get-buffer-path) " ")
                       'face (if (mode-line-window-selected-p)
                                 'my-mode-line-buffer-id
                               'mode-line-inactive)))

   ;; Git Branch (Only show when active)
   '(:eval (when (mode-line-window-selected-p)
             (propertize (my/get-git-branch)
                         'face 'my-mode-line-git-branch)))

   ;; Right Alignment Spacer
   '(:eval (my/mode-line-fill (if (mode-line-window-selected-p)
                                  'mode-line
                                'mode-line-inactive)
                              35))

   ;; Major Mode (Minimalist: No minor modes)
   '(:eval (propertize (format " %s " mode-name)
                       'face 'my-mode-line-major-mode))

   ;; Line:Column
   '(:eval (propertize " %l:%c "
                       'face (if (mode-line-window-selected-p)
                                 'mode-line
                               'mode-line-inactive)))

   ;; Percentage
   '(:eval (propertize " %p "
                       'face (if (mode-line-window-selected-p)
                                 'mode-line
                               'mode-line-inactive)))
   ))

;; Force update for all existing buffers
(defun my/apply-mode-line-format ()
  "Apply the custom mode line format to all buffers."
  (interactive)
  (message "Applying custom mode-line format...")
  ;; Re-apply faces in case a theme overwrote them
  (my/set-mode-line-faces)
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      ;; Kill local variable to fallback to default
      (kill-local-variable 'mode-line-format)
      ;; Sometimes killing isn't enough if default is polluted, so set it explicitly
      (setq mode-line-format (default-value 'mode-line-format))))
  (force-mode-line-update t)
  (message "Custom mode-line format applied."))

(my/apply-mode-line-format)

;; Re-apply mode-line faces AFTER any theme is loaded
;; This is crucial because doom-themes and other themes will override our settings
(add-hook 'after-load-theme-hook #'my/set-mode-line-faces)
;; Also hook into enable-theme-functions for Emacs 29+
(when (boundp 'enable-theme-functions)
  (add-hook 'enable-theme-functions (lambda (_) (my/set-mode-line-faces))))

;; Apply mode-line faces after Emacs finishes initialization
;; This ensures our settings take effect AFTER all themes are loaded
(add-hook 'emacs-startup-hook #'my/set-mode-line-faces)
;; Also apply after a short delay to handle lazy-loaded themes
(run-with-idle-timer 1 nil #'my/set-mode-line-faces)

(provide 'init-mode-line)
;;; init-mode-line.el ends here
