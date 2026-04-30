;;; init-shell-u.el --- Shell configuration using use-package  -*- lexical-binding: t -*-

;;; Commentary:
;; Configuration for vterm and other shell related packages.

;;; Code:

(use-package vterm
  :ensure t
  ;; vterm-keymap-exceptions 必须通过 customize 设置，用 setq 不会触发其 :set
  ;; 导致 vterm-mode-map 不会 unbind 这些键，C-v 等仍然会被 vterm 拦截
  :custom
  (vterm-keymap-exceptions
   '("C-c" "C-x" "C-u" "C-g" "C-h" "C-l" "M-x" "M-o" "C-v" "M-v" "C-y" "C-a" "M-:" "<escape>" "M-<escape>"))
  :config
  (setq vterm-max-scrollback 10000)
  (setq vterm-always-compile-module t)
  ;; 优化 vterm 性能：0.01 可能导致重绘过于频繁，0.04 是一个平衡点
  (setq vterm-timer-delay 0.04)

  ;; 设置 vterm 启动时使用登录shell以获取完整的nvm环境
  ;; 使用 -l 参数确保加载 .zshrc/.bashrc 等配置文件
  (setq vterm-shell (concat (or (getenv "SHELL") "/bin/zsh") " -l"))
  ;; 确保 vterm 的键映射不拦截 C-a 和 ESC
  (add-hook 'vterm-mode-hook
            (lambda ()
              ;; vterm-send-C-a 和 vterm-send-ESC 函数在 init-evil.el 中定义
              (when (fboundp 'vterm-send-C-a)
                (define-key vterm-mode-map (kbd "C-a") 'vterm-send-C-a))
              (when (fboundp 'vterm-send-ESC)
                (define-key vterm-mode-map (kbd "<escape>") 'vterm-send-ESC))
              (when (fboundp 'vterm-send-C-v)
                (define-key vterm-mode-map (kbd "C-v") 'vterm-send-C-v))
              (define-key vterm-mode-map (kbd "M-v") 'vterm-yank)
              (define-key vterm-mode-map (kbd "M-:") 'eval-expression)))

  ;; 性能优化：禁用行号、尾部空格显示和双向文本重排
  (add-hook 'vterm-mode-hook
            (lambda ()
              (display-line-numbers-mode -1)
              (setq show-trailing-whitespace nil)
              (setq-local bidi-display-reordering nil)
              (setq-local cursor-type 'box)
              ;; G 跳到 terminal cursor 位置（shell prompt），而不是 Emacs buffer 末尾
              ;; 避免 terminal 屏幕末尾的空行（terminal content 不一定填满整个屏幕）
              (evil-local-set-key 'normal (kbd "G") #'vterm-reset-cursor-point))))

(use-package multi-vterm
  :ensure t
  :after vterm
  :bind (("C-c T" . multi-vterm)              ; Create new vterm
         ("C-c n" . multi-vterm-next)          ; Switch to next vterm
         ("C-c p" . multi-vterm-prev)          ; Switch to previous vterm
         ("C-c P" . multi-vterm-project)       ; Open vterm in project root
         ("C-c T" . my/multi-vterm-toggle)     ; 避免和 todo 快捷键冲突，同时暴露此方法
         )
  :config
  (defun my/multi-vterm-toggle ()
    "Toggle the vterm window for current project."
    (interactive)
    (let ((vterm-window (seq-find (lambda (w)
                                    (with-current-buffer (window-buffer w)
                                      (eq major-mode 'vterm-mode)))
                                  (window-list))))
      (if vterm-window
          (delete-window vterm-window)
        (multi-vterm-project))))

  ;; Always open vterm from the right side with fixed width 90
  ;; Add reuse functionality to prevent creating new instances when zooming
  (add-to-list 'display-buffer-alist
               '("\\*vterminal.*"
                 (display-buffer-reuse-window
                  display-buffer-in-direction)
                 (direction . right)
                 (window-width . 90)
                 (reusable-frames . visible))))

(provide 'init-shell-u)
;;; init-shell-u.el ends here
