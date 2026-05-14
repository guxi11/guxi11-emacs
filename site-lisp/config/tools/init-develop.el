;;; init-develop --- Summary

;;; Commentary:

;;; Code:

;; complete
(add-hook 'org-mode-hook #'yas-minor-mode)

(defun lint-fix ()
  "Lint fix."
  (interactive)
  (shell-command (format "cd %s && npx eslint %s --fix" default-directory (buffer-file-name))))

(defun lint-fix-prog ()
  "Check if is prog mode and lint."
  (interactive)
  (if (derived-mode-p 'prog-mode)
      (lint-fix)))

(defun stylelint-fix ()
  "Stylelint fix."
  (interactive)
  (shell-command (format "cd %s && npx stylelint %s --fix" default-directory (buffer-file-name))))

(defun stylelint-fix-prog ()
  "Check if is prog mode and stylelint."
  (interactive)
  (if (derived-mode-p 'prog-mode)
      (stylelint-fix)))

;; (use-package blamer
;;   :ensure t
;;   :bind (("s-i" . blamer-show-commit-info)
;;          ("C-c i" . blamer-show-posframe-commit-info))
;;   :defer 20
;;   :custom
;;   (blamer-idle-time 1)
;;   (blamer-min-offset 10)
;;   :custom-face
;;   (blamer-face ((t :foreground "#7a88cf"
;;                    :background nil
;;                                         ;                  :height 140
;;                    :italic t)))
;;   :config
;;   (global-blamer-mode 1))

(defun my/dired-copy-dirname-as-kill ()
  "Copy the current directory into the kill ring."
  (interactive)
  (kill-new (replace-regexp-in-string "~/develop/Tencent/ww.*njlogic/" "" default-directory)))

(defun my/relative-path ()
  "copy relative path";;https://emacs.stackexchange.com/a/45424
  (interactive)
  (let ((root (vc-root-dir)))
    (message "DEBUG my/relative-path: vc-root-dir=%s expanded=%s default-directory=%s buffer-file-name=%s"
             root (when root (expand-file-name root)) default-directory buffer-file-name)
    (kill-new (file-relative-name
               buffer-file-name
               (unless (string= (expand-file-name root) (expand-file-name "~/")) root)))))

(defun my/absolute-path ()
  "copy absolute path"
  (interactive)
  (kill-new (buffer-file-name)))

(defun my/branch ()
  "Copy current git branch to kill ring."
  (interactive)
  (kill-new (magit-get-current-branch)))

;; AI
;; (use-package aidermacs
;;   :ensure t
;;   :defer t
;;   :bind (("C-c a" . aidermacs-transient-menu))
;;   :config
;;   :custom
;;   (aidermacs-default-chat-mode 'architect)
;;   (aidermacs-default-model "deepseek"))

;; translate: word at point, or region if active
(use-package go-translate
  :ensure t
  :defer t
  :bind (("s-t" . gt-do-translate)
         ("s-T" . gt-do-translate-prompt))
  :config
  (setq gt-langs '(en zh))
  (setq gt-default-translator
        (gt-translator
         :taker   (gt-taker :text 'word :pick nil)
         :engines (list (gt-google-engine) (gt-bing-engine))
         :render  (gt-buffer-render))))

;; mermaid-mode
(with-eval-after-load 'mermaid-mode
  (setq mermaid-flags "-s 3"))

(defun my/mermaid-compile-file ()
  "Compile the current file with mmdc, no prompt."
  (interactive)
  (require 'mermaid-mode)
  (mermaid-compile-file (buffer-file-name)))

(provide 'init-develop)
;;; init-develop.el ends here
