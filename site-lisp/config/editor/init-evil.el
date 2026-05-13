;;; init-evil --- Commentary:

;;; Commentary:

;;; code:

;;; ### no evil block ###
;;; --- 在没有evil模式的panel中使用

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

(setq evil-mode-line-format nil)
(setq evil-mode-line-tag nil)

(use-package evil
  :ensure t
  :init (evil-mode)
  :config
  (setq evil-search-module 'evil-search)
  ;; (setq evil-want-C-u-scroll t) ;; not working
  ;; gui only
  (setq evil-insert-state-cursor '((bar . 2) "#218871")
        evil-normal-state-cursor '(box "#ff657a"))
  (define-key evil-insert-state-map (kbd "s-v") 'yank)
  ;; default key bindings:
  ;;   H heading line
  ;;   L footer line
  (define-key evil-normal-state-map (kbd "TAB") 'outline-toggle-children)
  (define-key evil-normal-state-map (kbd "C-p") 'previous-buffer)
  (define-key evil-normal-state-map (kbd "C-n") 'next-buffer)
  (define-key evil-normal-state-map (kbd "C-c i") 'symbol-overlay-put)
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
  ;; tabs
  (define-key evil-normal-state-map (kbd "gp") 'tab-previous) ;'tab-next: gt
  (define-key evil-normal-state-map (kbd "gn") 'tab-next)
  ;; search
  (define-key evil-normal-state-map (kbd "M-s") 'blink-search)
  ;; scroll up down
  (define-key evil-normal-state-map (kbd "C-u") (lambda ()
                                                  (interactive)
                                                  (evil-scroll-up nil)))
  (define-key evil-normal-state-map (kbd "C-k") 'evil-scroll-line-up)
  ;; default eval-print-last-sexp
  (define-key evil-normal-state-map (kbd "C-j") 'evil-scroll-line-down)
  ;; unbind c, for vim-surround will use it
  (define-key evil-normal-state-map "S" 'evil-surround-change)

  (define-key evil-visual-state-map (kbd "gl") 'magit-log-buffer-file)

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
    "le" 'lint-fix
    "ls" 'stylelint-fix
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
    "rh" 'bookmark-bmenu-list
    "rb" 'bookmark-jump
    "rs" 'bookmark-set
    "rd" 'bookmark-delete
    ;; anzu
   	"pq" 'anzu-query-replace
	"pr" 'anzu-query-replace-regexp
	"pc" 'anzu-query-replace-at-cursor
	"pr" 'anzu-replace-at-cursor-thing
    ;; latex
    "pl" 'org-latex-preview
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
    ;; popweb
    "po" 'what-cursor-position
    ;; org
    "a" 'org-agenda
    ;; link
    "op" 'org-open-at-point
    "ol" 'my/open-link-at-point
    ;; counsel
    "F" 'counsel-projectile-grep
    "s" 'counsel-projectile-ag
    "x" 'counsel-M-x
	;; eval
	"d" 'eval-defun
	;; create snippet
    "cs" 'yas-new-snippet
	;; activities
	"cl" 'activities-list
	"cn" 'activities-new
	"cd" 'activities-define             ; C-u ~ redefine
	"cp" 'activities-suspend
	"ck" 'activities-kill
	"cr" 'activities-resume
	"cw" 'activities-switch
	"cm" 'activities-rename
	"cv" 'activities-revert
	"cx" 'activities-discard
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
    "ko" 'tab-close-other
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
    "gn" 'lsp-bridge-diagnostic-jump-next
    "gp" 'lsp-bridge-diagnostic-jump-prev
    "gl" 'lsp-bridge-diagnostic-copy
    "p" 'lsp-bridge-popup-documentation
    "sn" 'lsp-bridge-popup-documentation-scroll-down
    "sp" 'lsp-bridge-popup-documentation-scroll-up
    "M-," 'lsp-bridge-code-action
    "M-." 'lsp-bridge-find-references
    "n" 'lsp-bridge-rename
    "a" 'lsp-bridge-code-action
	)
  ;; treesit fold
  (define-prefix-command 'my-ts-map)
  (keymap-set evil-normal-state-map "M-f" 'my-ts-map)
  (evil-define-key nil my-ts-map
    ;; treesit-fold (for built-in tree-sitter modes)
    "o" 'treesit-fold-open              ; unfold at point
    "c" 'treesit-fold-close             ; fold at point
    "a" 'treesit-fold-open-all          ; unfold all
    "l" 'treesit-fold-close-all         ; fold all
    "f" 'treesit-fold-toggle            ; toggle fold at point
    "r" 'treesit-fold-open-recursively  ; unfold recursively
    "p" 'treesit-fold-previous          ; customized
    "n" 'treesit-fold-next              ; customized
	)
  ;; vterm
  (define-prefix-command 'my-multi-vterm-map)
  (keymap-set evil-normal-state-map "t" 'my-multi-vterm-map)
  (evil-define-key nil my-multi-vterm-map
    "t" 'my/multi-vterm-toggle
    "j" 'multi-vterm ;; create
    "p" 'multi-vterm-prev
    "n" 'multi-vterm-next
    "P" 'multi-vterm-project
    "c" 'my/set-frame-center
    "r" 'my/set-frame-right
    "s" 'my/set-frame-reset
    )
  ;; rest
  (define-prefix-command 'my-rest-map)
  (keymap-set evil-normal-state-map "r" 'my-rest-map)
  (evil-define-key nil my-rest-map
    "f" 'refresh-file
	)
  )

(evil-define-key 'normal vterm-mode-map (kbd "p") 'vterm-yank)
;; 在 vterm 中让 C-a 直接传递给终端，不触发 evil 命令
(defun vterm-send-C-a ()
  "Send C-a directly to vterm terminal."
  (interactive)
  (vterm-send-string "\C-a"))

;; 在 vterm 中让 ESC 直接传递给终端，不触发 evil 模式切换
(defun vterm-send-ESC ()
  "Send ESC directly to vterm terminal."
  (interactive)
  (vterm-send-string "\e"))

;; 在 vterm 中让 C-v 直接传递给终端（否则会被 evil 等 map 劫持成前缀键）
(defun vterm-send-C-v ()
  "Send C-v directly to vterm terminal."
  (interactive)
  (vterm-send-string "\C-v"))

(evil-define-key 'normal vterm-mode-map (kbd "C-a") 'vterm-send-C-a)
(evil-define-key 'insert vterm-mode-map (kbd "C-a") 'vterm-send-C-a)
(evil-define-key 'normal vterm-mode-map (kbd "<escape>") 'vterm-send-ESC)
(evil-define-key 'insert vterm-mode-map (kbd "<escape>") 'vterm-send-ESC)
(evil-define-key 'normal vterm-mode-map (kbd "M-<escape>") 'vterm-send-ESC)
(evil-define-key 'insert vterm-mode-map (kbd "M-<escape>") 'vterm-send-ESC)
(evil-define-key 'normal vterm-mode-map (kbd "C-v") 'vterm-send-C-v)
(evil-define-key 'insert vterm-mode-map (kbd "C-v") 'vterm-send-C-v)
(evil-define-key 'emacs  vterm-mode-map (kbd "C-v") 'vterm-send-C-v)

;;(add-hook
;; 'evil-normal-state-entry-hook (lambda () (set-face-background 'hl-line "#304157")))

(use-package treemacs-evil
  :ensure t
  :after (treemacs evil)
  ;; default config: https://github.com/Alexander-Miller/treemacs/blob/master/src/extra/treemacs-evil.el
  :config
  (define-key evil-treemacs-state-map (kbd "s") #'treemacs-switch-workspace)
  (define-key evil-treemacs-state-map (kbd "e") #'treemacs-select-window)
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
  :hook (org-mode . evil-org-mode)
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys)
  (evil-define-key 'motion org-agenda-mode-map
    "ci" #'org-agenda-clock-in
    "co" #'org-agenda-clock-out
    "cj" #'org-agenda-clock-goto
    "cq" #'org-agenda-clock-cancel
    "cv" #'org-agenda-clockreport-mode))

;; text object for org BEGIN/END blocks (yiq / diq / ciq etc.)
(evil-define-text-object evil-inner-org-block (count &optional beg end type)
  "Select inner content of org #+BEGIN_xxx / #+END_xxx block."
  (let ((block-beg (save-excursion
                     (when (re-search-backward "^[ \t]*#\\+BEGIN_" nil t)
                       (forward-line 1)
                       (point))))
        (block-end (save-excursion
                     (when (re-search-forward "^[ \t]*#\\+END_" nil t)
                       (forward-line -1)
                       (line-end-position)))))
    (when (and block-beg block-end (< block-beg block-end))
      (evil-range block-beg block-end 'line))))

(evil-define-text-object evil-a-org-block (count &optional beg end type)
  "Select org #+BEGIN_xxx / #+END_xxx block including delimiters."
  (let ((block-beg (save-excursion
                     (when (re-search-backward "^[ \t]*#\\+BEGIN_" nil t)
                       (beginning-of-line)
                       (point))))
        (block-end (save-excursion
                     (when (re-search-forward "^[ \t]*#\\+END_" nil t)
                       (forward-line 1)
                       (point)))))
    (when (and block-beg block-end (< block-beg block-end))
      (evil-range block-beg block-end 'line))))

(define-key evil-inner-text-objects-map "q" 'evil-inner-org-block)
(define-key evil-outer-text-objects-map "q" 'evil-a-org-block)

;; (evil-define-key 'normal evil-org-mode-map
;;                      (kbd ";") 'ace-window)

(use-package evil-escape
  :ensure t
  :init
  (evil-escape-mode)
  ;; (setq-default evil-escape-key-sequence "jj") ; use default fd
  (setq-default evil-escape-delay 0.2))

;; Smart Input Source - auto switch to English when leaving insert mode
(use-package sis
  :ensure t
  :config
  (sis-ism-lazyman-config
   "com.apple.keylayout.ABC"            ; English
   "com.apple.inputmethod.SCIM.ITABC")  ; Chinese
  ;; Auto switch to English when entering normal mode
  (sis-global-respect-mode t))

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
   '(anzu-replace-highlight ((t (:background "#fdf6e3" :foreground "#dc322f" :strike-through t :weight bold))))
   '(anzu-replace-to ((t (:background "#eee8d5" :foreground "#859900" :weight bold)))))
  )

(add-hook 'color-rg-mode-hook
          (lambda ()
            (run-at-time "0.1 sec" nil (lambda ()
                                         (evil-local-mode -1)
                                         (message "zyy 1")))))

(add-hook 'buffer-menu-mode-hook
          (lambda ()
            (run-at-time "0.1 sec" nil (lambda ()
                                         (evil-local-mode -1)
                                         (message "zyy 1")))))

(add-hook 'org-mode-hook
          (lambda ()
            (evil-local-set-key 'normal (kbd "TAB") 'org-cycle)))

(provide 'init-evil)
;;; init-evil.el ends here
