;;; init-theme --- Summery

;;; Commentary:

;;; Code:

;; basic
(setq display-line-numbers-type 'relative) ; （可选）显示相对行号

;; Theme
;; (use-package doom-themes
;;   :ensure t
;;   :config
;;   ;; Global settings (defaults)
;;   (setq doom-themes-enable-bold t ; if nil, bold is universally disabled
;; 	    doom-themes-enable-italic t) ; if nil, italics is universally disabled
;;   ;; (load-theme 'doom-monokai-octagon t)
;;   ;; (load-theme 'doom-palenight t)
;;   ;; (load-theme 'doom-gruvbox t)
;;   ;; (load-theme 'doom-solarized-light t)

;;   ;; Enable flashing mode-line on errors
;;   (doom-themes-visual-bell-config)
;;   ;; Disable doom-themes treemacs config — conflicts with treemacs-nerd-icons
;;   ;; (setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
;;   ;; (doom-themes-treemacs-config)
;;   ;; Corrects (and improves) org-mode's native fontification.
;;   (doom-themes-org-config))

(require 'init-monokai-pro-light-sun)

(require 'init-icons)

;; Better degration for color theme in terminal.
;; (use-package color-theme-approximate
;;   :ensure t)
;; (color-theme-approximate-on)

;; highlight current line
(global-hl-line-mode t)

(provide 'init-theme)

;;; init-theme.el ends here
