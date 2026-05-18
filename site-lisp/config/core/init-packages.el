;; init-packages --- Summery

;;; Commentary:

;;; Code:

;; (require 'package)
;; (setq package-archives '(("gnu"   . "http://mirrors.cloud.tencent.com/elpa/gnu/")
;;                          ("melpa" . "http://mirrors.cloud.tencent.com/elpa/melpa/")))
;; (package-initialize)
;; (package-refresh-contents)

(require 'package)

;; package-initialize already called in site-start.el

(use-package exec-path-from-shell
  :ensure t
  :defer t
  :if (memq window-system '(mac ns x)))

(when (memq window-system '(mac ns x))
  (require 'cache-path-from-shell)
  (setq exec-path-from-shell-arguments nil) ;; use non-interactive , in ~/.zshenv
  (setq exec-path-from-shell-variables
        '("PATH" "MANPATH" "NVM_DIR" "NODE_VERSION"
          "https_proxy" "http_proxy" "all_proxy" "HTTPS_PROXY" "HTTP_PROXY"))
  ;; defer shell spawn to idle time
  (run-with-idle-timer 0.5 nil #'exec-path-from-shell-initialize))

(use-package flx
  :ensure t)

(use-package counsel
  :ensure t)

(use-package ivy
  :ensure t
  :defer 0.5
  :init
  (ivy-mode 1)
  (counsel-mode 1)
  :config
  (setq ivy-use-virtual-buffers t)
  (setq search-default-mode #'char-fold-to-regexp)
  (setq ivy-count-format "(%d/%d) ")
  (setq ivy-virtual-abbreviate 'full)   ; 优化性能
  (setq ivy-extra-directories nil)      ; 优化性能，不显示 . 和 ..
  (setq ivy-on-del-error-function #'ignore)
  (setq ivy-dynamic-exhibit-delay-ms 20)
  ;; M-x 真模糊匹配：输入 "pkins" 能匹配 "package-install"，flx 负责智能排序
  (setq ivy-re-builders-alist
        '((counsel-M-x . ivy--regex-fuzzy)
          (t . ivy--regex-plus)))
  (setq ivy-initial-inputs-alist nil)  ; 去掉 M-x 默认的 "^" 前缀，否则模糊失效
  :bind
  (("C-s" . 'swiper)
   ("C-x b" . 'ivy-switch-buffer)   ("C-c v" . 'ivy-push-view)
   ("C-c s" . 'ivy-switch-view)
   ("C-c V" . 'ivy-pop-view)
   ("C-x C-@" . 'counsel-mark-ring) ; 在某些终端上 C-x C-SPC 会被映射为 C-x C-@，比如在 macOS 上，所以要手动设置
   ("C-x C-SPC" . 'counsel-mark-ring)
   :map minibuffer-local-map
   ("C-r" . counsel-minibuffer-history)))

;; ivy 卡死：通常是由于 ivy-use-virtual-buffers 开启后，recentf 列表中包含了无法访问的远程文件（如 SSH、TRAMP 路径）。当 ivy 尝试检查这些文件是否存在时，会导致 Emacs 界面冻结。此外，ivy-posframe 在处理大量数据或快速输入时也可能引起性能问题。
(use-package recentf
  :ensure t
  :defer 1
  :init
  (recentf-mode 1)
  :config
  (setq recentf-max-saved-items 300)
  (setq recentf-exclude '("/tmp/" "/ssh:" "/sudo:" "/scp:"))
  (setq recentf-auto-cleanup 'never))

;; (use-package ivy-posframe
;;   :ensure t
;;   :after ivy
;;   :init
;;   (setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display-at-frame-top-center)))
;;   ;; (setq ivy-posframe-height-alist '((t . 12)))
;;   (setq ivy-posframe-parameters '((internal-border-width . 20)
;;                                   (left-fringe . 0)
;;                                   (right-fringe . 0)))
;;   (setq ivy-posframe-width 100)
;;   ;; 仅在图形界面下启用 posframe
;;   (when (display-graphic-p)
;;     (ivy-posframe-mode 1)))

(use-package hydra
  :ensure t)

(use-package use-package-hydra
  :ensure t
  :after hydra)

;; 记录历史
(use-package amx
  :ensure t
  :defer 1
  :init (amx-mode))

;; 跳转
(use-package ace-window
  :ensure t
  :config
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  (setq aw-background nil)
  (setq aw-scope 'frame)

  (defun aw-copy-relative-path (window)
    "Copy the relative path of WINDOW's buffer without switching to it."
    (let* ((buf  (window-buffer window))
           (root (vc-root-dir))
           (root (unless (string= (expand-file-name root) (expand-file-name "~/")) root)))
      (if (buffer-file-name buf)
          (let ((path (file-relative-name (buffer-file-name buf) root)))
            (kill-new path)
            (message "Copied: %s" path))
        (message "Window has no file"))))

  (setq aw-dispatch-alist
        '((?p aw-copy-relative-path "Copy Relative Path")
          (?x aw-delete-window "Delete Window")
          (?m aw-swap-window "Swap Windows")
          (?n aw-flip-window)
          (?v aw-split-window-vert "Split Vert Window")
          (?b aw-split-window-horz "Split Horz Window")
          (?1 delete-other-windows "Delete Other Windows")
          (?? aw-show-dispatch-help)))

  :bind (("C-x o" . 'ace-window)))

(use-package which-key
  :ensure t
  :defer 1
  :init (which-key-mode))

;; filter, select, act
(use-package avy
  :ensure t
  :bind
  (("s-j" . avy-goto-char-timer)))

(use-package highlight-symbol
  :ensure t
  :defer t
  :hook (prog-mode . highlight-symbol-mode)
  :bind ("C-c h" . highlight-symbol))

(use-package projectile
  :ensure t
  :defer t
  :commands (projectile-project-root projectile-command-map)
  :bind (("s-p" . 'projectile-command-map))
  :config
  (setq projectile-mode-line "Projectile")
  (setq projectile-enable-caching t)
  (setq projectile-project-search-path '("~/.emacs.d" "~/develop/")))
;;(setq projectile-track-known-projects-automatically nil))

(use-package consult
  :ensure t
  :init
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)
  )

(use-package anzu                       ; replace
  :ensure t
  :config
  (setq anzu-replace-at-cursor-thing 'word))

(use-package counsel-projectile
  :ensure t
  :defer t
  :after (projectile)
  :commands (counsel-projectile-mode counsel-projectile-grep counsel-projectile-ag)
  :init
  (with-eval-after-load 'projectile (counsel-projectile-mode)))

(setq counsel-async-command-delay 0.3)
(setq which-key-idle-delay 0.3
      which-key-idle-secondary-delay 0.1)

(use-package magit
  :ensure t
  :defer t
  :commands (magit-status magit-file-dispatch magit-get-current-branch magit-toplevel magit-log-buffer-file)
  :config
  (setq magit-diff-refine-hunk 'all)
  ;; 优化全屏显示，使用官方推荐的函数
  (setq magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1)
  ;; 优化 Push 体验：10秒内完成的命令不自动弹出 process buffer，减少干扰
  (setq magit-process-popup-time 10)

  ;; 保存窗口配置，在 magit-status 打开时记录当前布局
  (defvar my-magit-saved-window-config nil
    "Saved window configuration before opening magit-status.")
  (defvar my-magit-saved-window nil
    "The window that invoked magit-status.")

  (defun my-magit-save-window-config (&rest _args)
    "Save current window config before magit displays buffer."
    (setq my-magit-saved-window-config (current-window-configuration))
    (setq my-magit-saved-window (selected-window)))

  (defun my-magit-quit-and-restore ()
    "Quit magit and restore window configuration."
    (interactive)
    (kill-buffer (current-buffer))
    (when my-magit-saved-window-config
      (set-window-configuration my-magit-saved-window-config)
      (setq my-magit-saved-window-config nil)))

  ;; 在显示 magit buffer 前保存窗口配置
  (advice-add 'magit-status :before #'my-magit-save-window-config)

  ;; Enter diff 时，在原来打开 magit 的 window 中打开文件
  (defun my-magit-diff-visit-file-other-window ()
    "Visit diff file in the window that invoked magit-status, at the hunk position."
    (interactive)
    (let ((file (magit-file-at-point t t)))
      (if file
          (if my-magit-saved-window-config
              (let (target-buffer target-pos)
                ;; Let magit resolve the exact hunk position
                (save-window-excursion
                  (magit-diff-visit-file file)
                  (setq target-buffer (current-buffer))
                  (setq target-pos (point)))
                ;; Restore our window layout and show file at hunk position
                (set-window-configuration my-magit-saved-window-config)
                (when (and target-buffer (window-live-p my-magit-saved-window))
                  (set-window-buffer my-magit-saved-window target-buffer)
                  (set-window-point my-magit-saved-window target-pos)
                  (select-window my-magit-saved-window)))
            (magit-diff-visit-file file))
        (user-error "No file at point"))))

  (define-key magit-diff-section-base-map (kbd "RET") #'my-magit-diff-visit-file-other-window)

  ;; 直接在 magit-status-mode-map 中用 define-key 绑定，优先级最高
  ;; 这会覆盖 Evil 的 q 绑定
  (define-key magit-status-mode-map "q" #'my-magit-quit-and-restore)

  ;; Pull(rebase upstream) + Push(upstream) 一键操作
  (defun my-magit-pull-rebase-then-push ()
    "Pull with rebase from upstream, then push to upstream."
    (interactive)
    (let ((default-directory (magit-toplevel)))
      (magit-run-git-async "pull" "--rebase")
      (set-process-sentinel
       (get-buffer-process (magit-process-buffer t))
       (lambda (process event)
         (when (and (string-match-p "finished" event)
                    (eq (process-exit-status process) 0))
           (magit-run-git-async "push")
           (message "Pull --rebase succeeded, pushing..."))
         (when (not (eq (process-exit-status process) 0))
           (message "Pull --rebase failed, aborting push.")
           (magit-process-sentinel process event))))))

  (transient-append-suffix 'magit-push "u"
    '("U" "Pull rebase + Push" my-magit-pull-rebase-then-push))

  ;; Fetch + Pull(rebase) 一键操作
  (defun my-magit-fetch-then-pull-rebase ()
    "Fetch from upstream, then pull with rebase."
    (interactive)
    (let ((default-directory (magit-toplevel)))
      (magit-run-git-async "fetch")
      (set-process-sentinel
       (get-buffer-process (magit-process-buffer t))
       (lambda (process event)
         (if (and (string-match-p "finished" event)
                  (eq (process-exit-status process) 0))
             (progn
               (magit-run-git-async "pull" "--rebase")
               (message "Fetch succeeded, pulling with rebase..."))
           (message "Fetch failed, aborting pull.")
           (magit-process-sentinel process event))))))

  (transient-append-suffix 'magit-pull "u"
    '("U" "Fetch + Pull --rebase" my-magit-fetch-then-pull-rebase))

  ;; 自动检测并复制 Push 输出中的 MR/PR 链接
  (defun my-magit-extract-mr-url (buf)
    "Scan BUF tail for MR URL and copy to kill ring."
    (when (and buf (buffer-live-p buf))
      (with-current-buffer buf
        (save-excursion
          (goto-char (point-max))
          (let* ((scan-start (max (point-min) (- (point-max) 4000)))
                 (url-pos (re-search-backward
                           "^remote:.*?\\(https?://[^ \t\n|]+\\)"
                           scan-start t)))
            (when url-pos
              (let ((url (match-string 1)))
                (kill-new url)
                (message "🔗 MR Link copied: %s" url))))))))

  ;; 给 sentinel 加 advice:这个是所有 magit 异步 git 进程完成的必经之路
  (defun my-magit-process-sentinel-advice (process event)
    "Extract MR URL when a git push/pull process finishes."
    (when (and (processp process)
               (memq (process-status process) '(exit signal))
               (let ((cmd (process-command process)))
                 (or (member "push" cmd)
                     (member "pull" cmd))))
      (my-magit-extract-mr-url (process-buffer process))))

  (advice-add 'magit-process-sentinel :after #'my-magit-process-sentinel-advice))

(use-package diff-hl
  :ensure t
  :defer t
  :hook (find-file . diff-hl-mode)
  :config
  (global-diff-hl-mode)
  ;; (if (not (display-graphic-p)) diff-hl-margin-mode)
  ;; (diff-hl-margin-mode)
  )

(with-eval-after-load 'magit
  (add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)

  ;; 强力的chaggpt 配置，能够刷新状态
  (defun my-diff-hl-magit-post-refresh ()
    (dolist (buf (buffer-list))
      (with-current-buffer buf
        (when diff-hl-mode
          (diff-hl-update)))))
  (add-hook 'magit-post-refresh-hook #'my-diff-hl-magit-post-refresh))

(use-package nerd-icons
  :ensure t
  :defer t)

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

  ;; Use mono font for all treemacs faces
  (dolist (face '(treemacs-directory-face
                  treemacs-directory-collapsed-face
                  treemacs-file-face
                  treemacs-root-face
                  treemacs-root-unreadable-face
                  treemacs-root-remote-face
                  treemacs-tags-face
                  treemacs-git-unmodified-face
                  treemacs-git-modified-face
                  treemacs-git-renamed-face
                  treemacs-git-ignored-face
                  treemacs-git-untracked-face
                  treemacs-git-added-face
                  treemacs-git-conflict-face))
    (set-face-attribute face nil :family "Maple Mono NF CN"))

  (add-hook 'treemacs-mode-hook
            (lambda () (setq-local line-spacing 2)))

  ;; Use SVG icons — bypasses font advance-width cropping in GUI
  (require 'nerd-svg-icons-treemacs-icons)
  (nerd-svg-icons-treemacs-icons-config)
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

;; (use-package treemacs-nerd-icons
;;   :ensure t)

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
  :defer 1
  :init (xclip-mode))

(use-package cal-china-x
  :ensure t
  :defer t
  :commands (calendar)
  :config
  (setq calendar-mark-holidays-flag t)
  (setq cal-china-x-important-holidays cal-china-x-chinese-holidays)
  (setq cal-china-x-general-holidays '((holiday-lunar 1 15 "元宵节")))
  (setq calendar-holidays
        (append cal-china-x-important-holidays
                cal-china-x-general-holidays)))

(use-package symbol-overlay
  :load-path "~/guxi11-emacs/site-lisp/extensions/symbol-overlay"
  :commands (symbol-overlay-put))

;; 正确禁用 Tramp 的方式
(setq tramp-mode nil)
(setq enable-remote-dir-locals nil)

(provide 'init-packages)

;;; init-packages.el ends here
