;;; init-develop --- Summary

;;; Commentary:

;;; Code:

(defun lint-fix ()
  "Lint fix."
  (interactive)
  (shell-command (format "cd %s && npx eslint %s --fix" default-directory (buffer-file-name))))

(defun lint-fix-prog ()
  "Check if is prog mode and lint."
  (interactive)
  (if (derived-mode-p 'prog-mode)
      (lint-fix)
    ()))

(use-package blamer
  :ensure t
  :bind (("s-i" . blamer-show-commit-info)
         ("C-c i" . blamer-show-posframe-commit-info))
  :defer 20
  :custom
  (blamer-idle-time 1)
  (blamer-min-offset 10)
  :custom-face
  (blamer-face ((t :foreground "#7a88cf"
                    :background nil
  ;                  :height 140
                    :italic t)))
  :config
  (global-blamer-mode 1))

(defun my/dired-copy-dirname-as-kill ()
  "Copy the current directory into the kill ring."
  (interactive)
  (kill-new (replace-regexp-in-string "/Users/yuanyuanzhang/develop/Tencent/ww.*njlogic/" "" default-directory)))

(defun my/relative-path ()
  "copy relative path";;https://emacs.stackexchange.com/a/45424
  (interactive)
  (kill-new (file-relative-name buffer-file-name (projectile-project-root))))

(provide 'init-develop)
;;; init-develop.el ends here
