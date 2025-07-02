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
			   (window-width . 66)
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
(add-to-list 'display-buffer-alist
             '("\\magit:"
               (display-buffer-in-side-window)
               (side . bottom)
               (window-height . 0.6)))
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

(provide 'init-window-u)
;;; init-window.el ends here
