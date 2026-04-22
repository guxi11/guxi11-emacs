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
  (kill-new (file-relative-name buffer-file-name (projectile-project-root))))

(defun my/absolute-path ()
  "copy absolute path"
  (interactive)
  (kill-new (buffer-file-name)))

;; AI
;; (use-package transient :ensure t) ;; 已经被依赖了
(use-package aider
  :ensure t
  :config
  ;; For latest claude sonnet model
  (setq aider-args '("--model" "deepseek" "--no-auto-accept-architect" "--no-auto-commits"))
  ;; (setenv "ANTHROPIC_API_KEY" "sk-")
  ;; (setenv "DEEPSEEK_API_KEY" "sk-")
  ;; Or gemini model
  ;; (setq aider-args '("--model" "gemini"))
  ;; (setenv "GEMINI_API_KEY" <your-gemini-api-key>)
  ;; Or chatgpt model
  ;; (setq aider-argsonal config file
  ;; (setq aider-args `("--config" ,(expand-file-name "~/.aider.conf.yml")))
  ;; ;;
  ;; Optional: Set a key binding for the transient menu
  (global-set-key (kbd "C-c a") 'aider-transient-menu))

(use-package aidermacs
  :ensure t
  :bind (("C-c a" . aidermacs-transient-menu))
  :config
  ; Set API_KEY in .bashrc, that will automatically picked up by aider or in elisp
  ;; (setenv "ANTHROPIC_API_KEY" "sk-...")
  ; defun my-get-openrouter-api-key yourself elsewhere for security reasons
  ;; (setenv "OPENROUTER_API_KEY" (my-get-openrouter-api-key))
  ;; (setq aidermacs-show-diff-after-change -1)
  :custom
  ; See the Configuration section below
  (aidermacs-default-chat-mode 'architect)
  (aidermacs-default-model "deepseek"))

(provide 'init-develop)
;;; init-develop.el ends here
