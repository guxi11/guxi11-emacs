;;; init-evil --- Commentary:

;;; Commentary:

;;; code:

(defun my/open-link-at-point ()
  "在光标处判断链接类型，http/https 用 EAF browser 打开，id: 用 org-roam 打开。"
  (interactive)
  (let* ((context (org-element-context)))
    (if (eq (org-element-type context) 'link)
        (let ((type (org-element-property :type context))
              (path (org-element-property :path context)))
          (cond
           ;; http/https 链接
           ((member type '("http" "https"))
            (eaf-open-browser path))
           ;; org-roam id: 链接
           ((string= type "id")
            (let ((node (org-roam-node-from-id path)))
              (if node
                  (org-roam-node-visit node)
                (message "未找到对应的 org-roam node: %s" path))))
           ;; 其他链接
           (t
            (message "不是支持的链接类型: %s" type))))
      (message "光标不在链接上"))))

(use-package evil
  :ensure t
  :init (evil-mode)
  :config
  (setq evil-search-module 'evil-search)
  ;; (setq evil-want-C-u-scroll t) ;; not working
  ;; gui only
  (setq evil-insert-state-cursor '((bar . 4) "yellow")
        evil-normal-state-cursor '(box "purple"))
  ;; default key bindings:
  ;;   H heading line
  ;;   L footer line
  (define-key evil-normal-state-map (kbd "t") 'outline-toggle-children)
  (define-key evil-normal-state-map (kbd "C-p") 'previous-buffer)
  (define-key evil-normal-state-map (kbd "C-n") 'next-buffer)
  ;; switch window
  (define-key evil-normal-state-map (kbd ";") 'ace-window)
  ;; register
  (define-key evil-normal-state-map (kbd "m") 'consult-register-store)
  (define-key evil-normal-state-map (kbd "'") 'consult-register-load)
  ;; visual-line, not actual line
  (define-key evil-normal-state-map (kbd "j") 'evil-next-visual-line)
  (define-key evil-normal-state-map (kbd "k") 'evil-previous-visual-line)
  ;; resizing window
  (define-key evil-normal-state-map (kbd "-") 'shrink-window-horizontally)
  (define-key evil-normal-state-map (kbd "=") 'enlarge-window-horizontally)
  (define-key evil-normal-state-map (kbd "_") 'shrink-window)
  (define-key evil-normal-state-map (kbd "+") 'enlarge-window)
  ; tabs
  (define-key evil-normal-state-map (kbd "gp") 'tab-previous) ;'tab-next: gt
  ; search
  (define-key evil-normal-state-map (kbd "M-s") 'blink-search)
  ;; scroll up down
  (define-key evil-normal-state-map (kbd "C-y") (lambda ()
                                                  (interactive)
                                                  (evil-scroll-up nil)))
  (define-key evil-normal-state-map (kbd "C-k") 'evil-scroll-line-up)
  ;; default eval-print-last-sexp
  (define-key evil-normal-state-map (kbd "C-j") 'evil-scroll-line-down)

  (define-prefix-command 'my-rg-map)
  (keymap-set evil-normal-state-map "M-r" 'my-rg-map)
  (evil-define-key nil my-rg-map
    "g" 'color-rg-search-symbol
    "h" 'color-rg-search-input
    "j" 'color-rg-search-symbol-in-project
    "k" 'color-rg-search-input-in-project
    "," 'color-rg-search-symbol-in-current-file
    "." 'color-rg-search-input-in-current-file
    )

  (define-prefix-command 'my-leader-map)
  (keymap-set evil-normal-state-map "SPC" 'my-leader-map)
  (evil-define-key nil my-leader-map
    ;; lint
    "l" 'lint-fix
    ;; buffer
    "b" 'switch-to-buffer
    "Bp" 'project-switch-to-buffer
	"Bi" 'ibuffer
    "f" 'project-find-file
    "w" 'save-buffer
    ;; comment
    ";" 'comment-or-uncomment-region
    ;; jump
    "[" 'diff-hl-show-hunk-previous
    "]" 'diff-hl-show-hunk-next
    "{" (lambda ()
		  (interactive)
		  (progn
			(diff-hl-show-hunk-previous)
			(evil-emacs-state)))
    "}" (lambda ()
		  (interactive)
		  (progn
			(diff-hl-show-hunk-next)
			(evil-emacs-state)))
    ;; bookmark
    "rh" 'helm-bookmarks
    "rb" 'bookmark-jump
    "rs" 'bookmark-set
    "rd" 'bookmark-delete
    ;; git
    "gs" 'magit-status
    "gf" 'magit-file-dispatch
    ;; window
    "h" 'split-window-right
    "v" 'split-window-below
    "q" 'delete-window
    "z" 'zoom-window-zoom
    "oo" 'switch-to-buffer-other-window
    "1" 'delete-other-windows
    ;; treemacs
    "e" 'treemacs-select-window
    "t" 'treemacs
    ;; org
    "a" 'org-agenda
    ;; link
    "ol" 'my/open-link-at-point
    ;; counsel
    "F" 'counsel-projectile-grep
    "s" 'counsel-projectile-ag
    "x" 'counsel-M-x
	;; eval
	"d" 'eval-defun
	;; create
                                        ;"cs" 'yas-new-snippet
	;; activities
	"cl" 'activities-list
	"cn" 'activities-new
	"cd" 'activities-define ; C-u ~ redefine
	"cp" 'activities-suspend
	"ck" 'activities-kill
	"cr" 'activities-resume
	"cw" 'activities-switch
	"cm" 'activities-rename
	"cv" 'activities-revert
	;;
	"nn" 'evil-search-highlight-persist-remove-all
    ;; roam
    "nl" 'org-roam-buffer-toggle
    "nf" 'org-roam-node-find
    "ng" 'org-roam-graph
    "ni" 'org-roam-node-insert-immediate
    "nc" 'org-roam-capture
    ;; "nd" 'org-roam-dailies-map
    "ndg" 'org-roam-dailies-goto-date
    "ndd" 'org-roam-dailies-capture-date
    "ndt" 'org-roam-dailies-capture-today
    "ndy" 'org-roam-dailies-capture-yesterday
    ;; kill
    "ke" 'kill-emacs
    )
  (define-prefix-command 'my-lsp-map)
  (keymap-set evil-normal-state-map "s" 'my-lsp-map)
  (evil-define-key nil my-lsp-map ;; lsp-bridge
    "d" 'lsp-bridge-find-def
    "od" 'lsp-bridge-find-def-other-window
    "t" 'lsp-bridge-find-type-def
    "ot" 'lsp-bridge-find-type-def-other-window
    "i" 'lsp-bridge-find-impl
    "oi" 'lsp-bridge-find-impl-other-window
    "r" 'lsp-bridge-find-def-return
    "f" 'lsp-find-references
	)
  ;; hs
  (define-prefix-command 'my-hs-map)
  (keymap-set evil-normal-state-map "r" 'my-hs-map)
  (evil-define-key nil my-hs-map
    "sa" 'hs-show-all
    "sb" 'hs-show-block
    "ha" 'hs-hide-all
    "hb" 'hs-hide-block
    "hl" 'hs-hide-level
	)
  )

(add-hook
 'evil-normal-state-entry-hook (lambda () (set-face-background 'hl-line "#304157")))

(use-package treemacs-evil
  :ensure t
  :after (treemacs evil)
  ;; default config: https://github.com/Alexander-Miller/treemacs/blob/master/src/extra/treemacs-evil.el
  :config
  (define-key evil-treemacs-state-map (kbd "s") #'treemacs-switch-workspace)
  )

(use-package evil-surround
  :ensure t
  :config
  (global-evil-surround-mode 1))

(use-package evil-commentary
  :ensure t
  :init
  (evil-commentary-mode))

(use-package evil-org
  :ensure t
  :after org
  :hook (org-mode . (lambda () evil-org-mode))
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

;; (evil-define-key 'normal evil-org-mode-map
;;                      (kbd ";") 'ace-window)

(use-package evil-escape
  :ensure t
  :init
  (evil-escape-mode)
  ;; (setq-default evil-escape-key-sequence "jj") ; use default fd
  (setq-default evil-escape-delay 0.2))

;; evil needed
(use-package goto-chg
  :ensure t)

(use-package highlight
  :ensure t)

(use-package evil-search-highlight-persist
  :ensure t
  :config
  ;; To only display string whose length is greater than or equal to 3
  ;; (setq evil-search-highlight-string-min-len 3)
  (global-evil-search-highlight-persist t)
  (custom-set-faces
   '(anzu-replace-highlight ((t (:background "#511f2b" :foreground "#ff5370" :strike-through t :weight bold))))
   '(anzu-replace-to ((t (:background "#1c4f30" :foreground "#00ff30" :weight bold)))))
  )

(add-hook 'color-rg-mode-hook
          (lambda ()
            (run-at-time "0.1 sec" nil (lambda ()
                                         (evil-local-mode -1)
                                         (message "zyy 1")))))
(provide 'init-evil)
;;; init-evil.el ends here
