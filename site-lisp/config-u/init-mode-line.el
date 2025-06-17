;;; init-mode-line --- Summary

;;; Commentary:

;;; Code:

(line-number-mode 1)
(column-number-mode 1)

(setq
 my-mode-line-identifier
 '(:eval (if (mode-line-window-selected-p)
			 "1"
		   "0")))

(setq mode-line-position
      '(;; %p print percent of buffer above top of window, o Top, Bot or All
        ;; (-3 "%p")
        ;; %I print the size of the buffer, with kmG etc
        ;; (size-indication-mode ("/" (-4 "%I")))
        ;; " "
        ;; %l print the current line number
        ;; %c print the current column
        (line-number-mode ("%l" (column-number-mode ":%c")))))

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
    (:eval (if (buffer-file-name) (concat " " (shorten-directory default-directory 20)) " "))
    face mode-line-directory)
  "Formats the current directory.")
(put 'mode-line-directory 'risky-local-variable t)

(setq-default mode-line-buffer-identification
              (propertized-buffer-identification "%b "))
(setq-default
 mode-line-buffer-identification
 '(:eval (propertize "%12b"
		     'face (if (mode-line-window-selected-p)
			       'bold
			     'italic))))
(setq-default
 mode-line-format
 '(
   ;;my-mode-line-identifie
   "%e"
   mode-line-front-space
   ;;mode-line-mule-info
   mode-line-position
   mode-line-frame-identification
   " "
   mode-line-directory
   mode-line-buffer-identification
   " "
   (vc-mode vc-mode)
   mode-name
   mode-line-end-spaces))

(force-mode-line-update t)

;;(setq-default mode-line-format nil)

(provide 'init-mode-line)
;;; init-mode-line.el ends here
