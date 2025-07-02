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

;; AI
;; (use-package transient :ensure t) ;; 已经被依赖了
(use-package aider
  :ensure t
  :config
  ;; For latest claude sonnet model
  (setq aider-args '("–no-auto-commits" "--model" "deepseek" "--no-auto-accept-architect"))
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

(provide 'init-develop)
;;; init-develop.el ends here
