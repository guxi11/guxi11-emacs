;;; init-theme --- Summery

;;; Commentary:

;;; Code:

;; basic
(setq display-line-numbers-type 'relative)   ; （可选）显示相对行号

;; Theme
(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
	doom-themes-enable-italic t) ; if nil, italics is universally disabled
  ;; (load-theme 'doom-monokai-octagon t)
  (load-theme 'doom-palenight t)
  ;; (load-theme 'doom-gruvbox t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; (setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
  (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

;(when (display-graphic-p) (use-package all-the-icons))
(use-package all-the-icons)

(use-package nerd-icons
	:ensure t
  ;; :custom
  ;; The Nerd Font you want to use in GUI
  ;; "Symbols Nerd Font Mono" is the default and is recommended
  ;; but you can use any other Nerd Font if you want
  )

;; (use-package nerd-icons-dired
;;   :ensure t
;;   :hook
;;   (dired-mode . nerd-icons-dired-mode))

;; (use-package treemacs-nerd-icons
;; 	:ensure t
;; 	:config
;;   (treemacs-load-theme "nerd-icons"))

;; Better degration for color theme in terminal.
;; (use-package color-theme-approximate
;;   :ensure t)
;; (color-theme-approximate-on)

;; (use-package smart-mode-line
;;   :ensure t
;;   :init
;;   ; (setq sml/no-confirm-load-theme t)  ; avoid asking when startup
;;   (sml/setup)
;;   :config
;;   (setq rm-blacklist
;;     (format "^ \\(%s\\)$"
;;       (mapconcat #'identity
;;         '("Projectile.*" "company.*" "Google"
;; 	  "Undo-Tree" "counsel" "ivy" "yas" "WK"
;; 	  "FlyC" "ElDoc" "hs" "jj")
;;          "\\|"))))

;; face
;; highlight current line
(global-hl-line-mode t)
;; (set-face-attribute 'region nil :background "#8f4269")
(set-face-background 'hl-line "gray10")

;; should only contain one in init file
(custom-set-variables
  '(zoom-window-mode-line-color "dark cyan"))

;; should only contain one in init file
(custom-set-faces
 '(anzu-replace-highlight ((t (:background "#511f2b" :foreground "#ff5370" :strike-through t :weight bold))))
 '(anzu-replace-to ((t (:background "#1c4f30" :foreground "#00ff30" :weight bold))))
'(ivy-current-match ((t (:extend t :background "brown4"))))
 '(ivy-org ((t (:foreground "brightyellow" :slant italic))))
 '(lazy-highlight ((t (:background "#f06070" :foreground "#EEFFFF" :weight bold))))
 '(mode-line ((t (:background "dark slate blue" :foreground "moccasin" :box nil))))
 '(mode-line-inactive ((t (:background "#202030" :foreground "gray70" :box nil))))
 '(tab-bar-tab ((t (:background "white" :foreground "VioletRed1" :weight bold :box nil))))
 '(vertical-border ((t (:background "#292d3e")))))


(provide 'init-theme)

;;; init-theme.el ends here
