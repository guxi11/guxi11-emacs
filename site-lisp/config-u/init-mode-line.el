;;; init-mode-line --- Summary

;;; Commentary:

;;; Code:

(line-number-mode 1)
(column-number-mode 1)

;; (defface mode-line-directory
;;   '((t :foreground "gray"))
;;   "Face used for buffer identification parts of the mode line."
;;   :group 'mode-line-faces
;;   :group 'basic-faces)

(setq mode-line-position
      '(;; %p print percent of buffer above top of window, o Top, Bot or All
        ;; (-3 "%p")
        ;; %I print the size of the buffer, with kmG etc
        ;; (size-indication-mode ("/" (-4 "%I")))
        ;; " "
        ;; %l print the current line number
        ;; %c print the current column
        (line-number-mode ("%l" (column-number-mode ":%c")))))

(setq mode-line-position
      '((:eval
         (propertize
          (concat
           (when line-number-mode
             (format "%d" (line-number-at-pos)))
           (when column-number-mode
             (format ":%d" (current-column))))
          'face (if (mode-line-window-selected-p)
                    '(:foreground "brown1" :weight bold)
                '(:foreground "brown3" :weight bold)
                  )))))

(defun shorten-directory (dir max-length)
  "Show up to `max-length' characters of a directory name `dir'."
  (let ((path (reverse (split-string (abbreviate-file-name dir) "/")))
        (output ""))
    (when (and path (equal "" (car path)))
      (setq path (cdr path)))
    (while (and path (< (length output) (- max-length 4)))
      (setq output (concat (car path) "/" output))
      (setq path (cdr path)))
    (when path
      (setq output (concat "" output)))
    output))

(defvar mode-line-directory
  '(:propertize
    (:eval (if (buffer-file-name) (concat "" (shorten-directory default-directory 20)) " "))
    face mode-line-directory)
  "Formats the current directory.")

(put 'mode-line-directory 'risky-local-variable t)

(setq-default mode-line-buffer-identification
              (propertized-buffer-identification "%b "))

(setq-default
 mode-line-buffer-identification
 '(:eval (propertize "%12b"
		             'face (if (mode-line-window-selected-p)
			                   '(:foreground "VioletRed1" :weight bold)
			                 '(:foreground "pink1" :weight bold)))))

(defun my/git-repo-name ()
  "Return the name of the current Git repository, or nil if not in a repo."
  (interactive)
  (let* ((root (locate-dominating-file default-directory ".git")))
    (when root
      (file-name-nondirectory (directory-file-name root)))))

(setq-default
 mode-line-format
 '(
   "%e"
   mode-line-front-space
   ;;mode-line-mule-info
   mode-line-position
   mode-line-frame-identification
   ;;" "
   mode-line-directory
   mode-line-buffer-identification
   " "
   '(:eval (when (my/git-repo-name)
             (format "[%s] " (my/git-repo-name))))
   (vc-mode vc-mode)
   " "
   mode-name
   mode-line-end-spaces))

(force-mode-line-update t)

;;(setq-default mode-line-format nil)

(provide 'init-mode-line)
;;; init-mode-line.el ends here
