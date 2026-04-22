;;; init-monokai-pro-light-sun.el --- Monokai Pro Light Sun Theme configuration  -*- lexical-binding: t; -*-

;;; Commentary:
;; Configuration for Monokai Pro Light Sun theme.

;;; Code:

(use-package monokai-pro-theme
  ;; :ensure t
  :ensure nil
  :load-path "~/guxi11-emacs/site-lisp/extensions/emacs-monokai-pro-theme/"
  :config
  (load-theme 'monokai-pro-light-sun t))

;; for light-sun
(custom-set-faces
 '(org-document-title ((t (:background nil :foreground "#ce4770" :weight bold))))
 '(org-drawer ((t (:background nil :foreground "#8e8791"))))
 '(org-block ((t (:background "#f1e7de" :extend t))))
 '(fringe ((t (:background nil :foreground "#b1a9b5")))) ;; 折行的符号
 )

;; Magit faces
(custom-set-faces
 '(magit-diff-context ((t (:background "#f8efe7" :foreground "#657b83"))))
 '(magit-diff-context-highlight ((t (:background "#f3e9e1" :foreground "#657b83"))))
 
 ;; Hunk Headings (Thunk Bar)
 '(magit-diff-hunk-heading ((t (:background "#ede0d5" :foreground "#657b83"))))
 '(magit-diff-hunk-heading-highlight ((t (:background "#e1ccb9" :foreground "#657b83"))))
 
 ;; Section Highlight
 '(magit-section-highlight ((t (:background "#ede0d5"))))
 
 ;; Added (Lighter/More Transparent-like)
 '(magit-diff-added ((t (:background "#f1fdf4" :foreground "#2aa198"))))
 '(magit-diff-added-highlight ((t (:background "#e6ffed" :foreground "#2aa198"))))
 
 ;; Removed (Lighter/More Transparent-like)
 '(magit-diff-removed ((t (:background "#fdf2f2" :foreground "#dc322f"))))
 '(magit-diff-removed-highlight ((t (:background "#ffeef0" :foreground "#dc322f"))))

 ;; Refine (Intra-line changes)
 '(magit-diff-refine-added ((t (:background "#cbf7d6" :foreground "#218871" :weight bold))))
 '(magit-diff-refine-removed ((t (:background "#f7cbcb" :foreground "#ce4770" :weight bold)))))

;; diff-hl faces
(with-eval-after-load 'diff-hl
  (set-face-attribute 'diff-hl-change nil :background "#fd971f" :foreground "#fd971f")
  (set-face-attribute 'diff-hl-delete nil :background "#ce4770" :foreground "#ce4770")
  (set-face-attribute 'diff-hl-insert nil :background "#218871" :foreground "#218871"))

;; (with-eval-after-load 'acm
;;   (set-face-background 'acm-frame-default-face "#111213")
;;   (set-face-background 'acm-frame-border-face "gray20")
;;   (set-face-foreground 'acm-frame-select-face "#ffe4b5") ;; moccasin - warm sand
;;   (set-face-background 'acm-frame-select-face "#a0522d")) ;; sienna - earth tone

;; activities (delayed - face not available at startup)
(with-eval-after-load 'activities
  (set-face-foreground 'activities-tabs "#ce4770")) ;; fire orange

(set-face-attribute 'region nil :background "#ffcccc") ;; selected region - light red

;; should only contain one in init file
(custom-set-faces
 '(anzu-replace-highlight ((t (:background "#5d4037" :foreground "#ff6b35" :strike-through t :weight bold)))) ;; earth brown bg, fire orange fg
 '(anzu-replace-to ((t (:background "#3d2b1f" :foreground "#f39c12" :weight bold)))) ;; dark earth bg, golden flame fg
 ;; Example: change the flash background to yellow
 '(lsp-bridge-font-lock-flash ((t (:background "yellow" :foreground "black"))))
 '(ivy-current-match ((t (:extend t :background "#8b4513")))) ;; sienna - earth
 '(ivy-org ((t (:foreground "#e25016" :slant italic)))) ;; golden flame
 '(ivy-posframe ((t (:background "#f1e7de"))))
 '(ivy-posframe-border ((t (:background "#f1e7de"))))
 ;; '(vertical-border ((t (:foreground "#4a4545" :background "#242222"))))
 )

;; should only contain one in init file
(custom-set-variables
 '(zoom-window-mode-line-color "dark cyan"))

;; treesit-fold faces
(with-eval-after-load 'treesit-fold
  (set-face-attribute 'treesit-fold-replacement-face nil
                      :background "#e8d5c4"     ; 比代码块略深的暖色背景
                      :foreground "#ce4770"     ; 温暖的棕色
                      :box '(:line-width -1 :color "#d4c4b0" :style nil)))

;; treemacs faces
(with-eval-after-load 'treemacs
  (set-face-attribute 'treemacs-directory-face nil :foreground "#000000")  ; folder name - black
  (set-face-attribute 'treemacs-fringe-indicator-face nil :foreground "#888888"))  ; $ overflow symbol - gray
                      
(require 'init-tab-bar-light-sun)

;; hide docoration (top bar and border)
;;(set-frame-parameter (selected-frame) 'undecorated t)

(provide 'init-monokai-pro-light-sun)

;;; init-monokai-pro-light-sun.el ends here
