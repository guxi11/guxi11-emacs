;; init-packages --- Summery

;;; Commentary:

;;; Code:

;; (require 'package)
;; (setq package-archives '(("gnu"   . "http://mirrors.cloud.tencent.com/elpa/gnu/")
;;                          ("melpa" . "http://mirrors.cloud.tencent.com/elpa/melpa/")))
;; (package-initialize)
;; (package-refresh-contents)

(require 'package)

(setq package-archives
      '(("gnu"   . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))
                                        ;(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;;Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;;and `package-pinned-packages`. Most users will not need or want to do this.
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

(use-package counsel
  :ensure t)

(use-package ivy
  :ensure t
  :init
  (ivy-mode 1)
  (counsel-mode 1)
  :config
  (setq ivy-use-virtual-buffers t)
  (setq search-default-mode #'char-fold-to-regexp)
  (setq ivy-count-format "(%d/%d) ")
  :bind
  (("C-s" . 'swiper)
   ("C-x b" . 'ivy-switch-buffer)
   ("C-c v" . 'ivy-push-view)
   ("C-c s" . 'ivy-switch-view)
   ("C-c V" . 'ivy-pop-view)
   ("C-x C-@" . 'counsel-mark-ring); 在某些终端上 C-x C-SPC 会被映射为 C-x C-@，比如在 macOS 上，所以要手动设置
   ("C-x C-SPC" . 'counsel-mark-ring)
   :map minibuffer-local-map
   ("C-r" . counsel-minibuffer-history)))

(use-package hydra
  :ensure t)

(use-package use-package-hydra
  :ensure t
  :after hydra)

;; 记录历史
(use-package amx
  :ensure t
  :init (amx-mode))

;; 跳转
(use-package ace-window
  :ensure t
  :config
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  (setq aw-background nil)
  (setq aw-scope 'frame)
  :bind (("C-x o" . 'ace-window)))

(use-package which-key
  :ensure t
  :init (which-key-mode))

;; filter, select, act
(use-package avy
  :ensure t
  :bind
  (("s-j" . avy-goto-char-timer)))

(use-package highlight-symbol
  :ensure t
  :init (highlight-symbol-mode)
  :bind ("C-c h" . highlight-symbol)) ;; 高亮当前符号

(use-package projectile
  :ensure t
  :bind (("s-p" . 'projectile-command-map))
  :config
  (setq projectile-mode-line "Projectile")
  (setq projectile-project-search-path '("~/.emacs.d" "~/develop/")))
;;(setq projectile-track-known-projects-automatically nil))

(use-package consult
  :ensure t
  :init
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)
  )

(use-package anzu ; replace
  :ensure t
  :config
  (setq anzu-replace-at-cursor-thing 'word))

(use-package counsel-projectile
  :ensure t
  :after (projectile)
  :init (counsel-projectile-mode))

(use-package magit
  :ensure t
  :config
  (setq magit-diff-refine-hunk 'all))

(use-package diff-hl
  :ensure t
  :config
  (global-diff-hl-mode)
  (if (not (display-graphic-p)) diff-hl-margin-mode)
  (diff-hl-margin-mode))

(add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)
(add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)

(use-package treemacs
  :ensure t
  :defer t
  :config
  ;; (treemacs-tag-follow-mode)
  (treemacs-follow-mode)
  (treemacs-git-mode 'deferred)
  (treemacs-project-follow-mode)
  (treemacs-filewatch-mode)
  (treemacs-define-RET-action 'file-node-open   #'treemacs-visit-node-in-most-recently-used-window)
  (treemacs-define-RET-action 'file-node-closed #'treemacs-visit-node-in-most-recently-used-window)

  ;; (treemacs-resize-icons 44)
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)
        ;; ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag))
  (:map treemacs-mode-map
	    ("/" . treemacs-advanced-helpful-hydra)))

(use-package treemacs-projectile
  :ensure t
  :after (treemacs projectile))

(use-package treemacs-magit
  :ensure t
  :after (treemacs))

(use-package treemacs-icons-dired
  :hook (dired-mode . treemacs-icons-dired-enable-once)
  :ensure t)

(use-package treemacs-icons-dired
  :ensure t
  :after (treemacs)
  :config
  (treemacs-icons-dired-mode 1))

;;(setq lsp-headerline-arrow "‣")

(use-package reveal-in-osx-finder
  :ensure t)

;;(use-package yasnippet
;;  :ensure t
;;  :config
;;  (setq yas-snippet-dirs '("~/org/snippets"))
;;  (yas-global-mode 1))

(use-package xclip
  :ensure t
  :init (xclip-mode))

(use-package cal-china-x
  :ensure t
  :config
  (setq calendar-mark-holidays-flag t)
  (setq cal-china-x-important-holidays cal-china-x-chinese-holidays)
  (setq cal-china-x-general-holidays '((holiday-lunar 1 15 "元宵节")))
  (setq calendar-holidays
        (append cal-china-x-important-holidays
                cal-china-x-general-holidays)))

(provide 'init-packages)

;;; init-packages.el ends here
