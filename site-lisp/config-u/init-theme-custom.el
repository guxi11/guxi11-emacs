;;; init-theme-custom --- Summery

;;; Commentary:

;;; Code:
(use-package smart-mode-line
  :ensure t
  :init
  ; (setq sml/no-confirm-load-theme t)  ; avoid asking when startup
  (sml/setup)
  :config
  (setq rm-blacklist
    (format "^ \\(%s\\)$"
      (mapconcat #'identity
        '("Projectile.*" "company.*" "Google"
	  "Undo-Tree" "counsel" "ivy" "yas" "WK"
	  "FlyC" "ElDoc" "hs" "jj")
         "\\|"))))

(custom-set-variables
  '(zoom-window-mode-line-color "#40131a"))

(custom-set-faces
 '(tab-bar-tab ((t (:background "#634061" :foreground "#EEFFFF" :box nil))))
 '(lazy-highlight ((t (:background "#f06070" :foreground "#EEFFFF" :weight bold))))
;; If there is more than one, they won't work right.
 '(mode-line-inactive ((t (:background "#281832" :foreground "#676E95" :box nil))))
 '(vertical-border ((t (:background "#292d3e"))))
 '(ivy-current-match ((t (:extend t :background "#6C435E"))))
 '(ivy-org ((t (:foreground "brightyellow" :slant italic)))))

(provide 'init-theme-custom)

;;; init-theme-custom.el ends here
