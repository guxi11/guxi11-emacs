;;; init-window-u --- Summary

;;; Commentary:

;;; Code:

(winner-mode t) ;; restore layout
(setq help-window-select t) ;; select help window, to quit

(use-package zoom-window
  :ensure t)

;; window management
(setq switch-to-buffer-in-dedicated-window 'pop)
(setq switch-to-buffer-obey-display-actions t)

(add-to-list 'display-buffer-alist
			 '("\\*Agenda Commands\\*"
			   (display-buffer-below-selected)))
(add-to-list 'display-buffer-alist
			 '("\\*Org Agenda\\*"
               (display-buffer-in-direction)
               ;; (window . root)
               ;; (dedicated . t)
			   (window-width . 70)
               (direction . right)
			   ))
(add-to-list 'display-buffer-alist
             '((major-mode . org-mode)
               (display-buffer-same-window
                display-buffer-below-selected)
			   (mode org-mode)
               ))
;; info, help
(add-to-list 'display-buffer-alist
             '((or (major-mode . Info-mode)
                   (major-mode . info-mode)
                   (major-mode . help-mode))
               (display-buffer-reuse-mode-window
                display-buffer-below-selected)
               ))
;; (display-buffer-reuse-window
;;  display-buffer-in-side-window)
;; (reusable-frames . visible)
;; (side . right)
;; (window-width . 80)))

(add-to-list 'display-buffer-alist
             `((major-mode . calendar-mode)
			   (display-buffer-in-direction)
			   (direction . top)))

;; Required. But note that this _does_ change Magit's default buffer display behavior.
;; (setq magit-display-buffer-function #'display-buffer)
;; (add-to-list 'display-buffer-alist
;;           `((derived-mode . magit-mode)
;;             (display-buffer-below-selected)
;;             (mode magit-mode)
;;             (window-height . 0.50)
;;             ))
;; (add-to-list 'display-buffer-alist
;;              '("\\magit:"
;;                (display-buffer-in-side-window)
;;                (side . bottom)
;;                (window-height . 0.6)))
(add-to-list 'display-buffer-alist
             '("\\magit-diff:"
               (display-buffer-in-direction)
               (direction . left)))
(add-to-list 'display-buffer-alist
             '("\\magit-revision:"
               (display-buffer-in-direction)
               (direction . right)))
;; org-roam
(add-to-list 'display-buffer-alist
			 '("\\*org-roam\\*"
               ;; (display-buffer-in-direction)
               (display-buffer-below-selected)
			   ;; (window-width . 0.4)
               ;; (direction . bottom)
			   ))

(setq default-frame-alist '((undecorated . t)))

(defconst my/frame-margin-left   100)
(defconst my/frame-margin-top     30)
(defconst my/frame-margin-right  100)
(defconst my/frame-margin-bottom  30)

(defun my/workarea ()
  (alist-get 'workarea (car (display-monitor-attributes-list))))

(defun my/set-frame-geometry (&optional frame)
  "Full screen minus margins."
  (let* ((f  (or frame (selected-frame)))
         (wa (my/workarea))
         (wa-x (nth 0 wa)) (wa-y (nth 1 wa))
         (wa-w (nth 2 wa)) (wa-h (nth 3 wa))
         (cw (frame-char-width f)) (ch (frame-char-height f))
         (cols (/ (- wa-w my/frame-margin-left my/frame-margin-right) cw))
         (rows (/ (- wa-h my/frame-margin-top  my/frame-margin-bottom) ch)))
    (set-frame-position f (+ wa-x my/frame-margin-left) (+ wa-y my/frame-margin-top))
    (set-frame-size     f cols rows)))

(defun my/set-frame-right ()
  "Right half of workarea with margins."
  (interactive)
  (let* ((f  (selected-frame))
         (wa (my/workarea))
         (wa-x (nth 0 wa)) (wa-y (nth 1 wa))
         (wa-w (nth 2 wa)) (wa-h (nth 3 wa))
         (half (/ wa-w 2))
         (cw (frame-char-width f)) (ch (frame-char-height f))
         (cols (/ (- half my/frame-margin-left my/frame-margin-right) cw))
         (rows (/ (- wa-h my/frame-margin-top  my/frame-margin-bottom) ch)))
    (set-frame-position f (+ wa-x half my/frame-margin-left) (+ wa-y my/frame-margin-top))
    (set-frame-size     f cols rows)))

(defun my/set-frame-center ()
  "2/3 width and 2/3 height, centered, with margins."
  (interactive)
  (let* ((f  (selected-frame))
         (wa (my/workarea))
         (wa-x (nth 0 wa)) (wa-y (nth 1 wa))
         (wa-w (nth 2 wa)) (wa-h (nth 3 wa))
         (fw (/ (* wa-w 2) 3)) (fh (/ (* wa-h 2) 3))
         (cw (frame-char-width f)) (ch (frame-char-height f))
         (cols (/ (- fw my/frame-margin-left my/frame-margin-right) cw))
         (rows (/ (- fh my/frame-margin-top  my/frame-margin-bottom) ch)))
    (set-frame-position f (+ wa-x (/ (- wa-w fw) 2) my/frame-margin-left)
                          (+ wa-y (/ (- wa-h fh) 2) my/frame-margin-top))
    (set-frame-size     f cols rows)))

(defun my/set-frame-reset ()
  "Reset frame to initial full geometry."
  (interactive)
  (my/set-frame-geometry))

(add-hook 'after-make-frame-functions #'my/set-frame-geometry)
(add-hook 'after-init-hook            #'my/set-frame-geometry)

(provide 'init-window-u)
;;; init-window.el ends here
