;;; init-u.el --- Load the foll configuration
;;; Commentary:

;; This file bootstraps the configruation, which is divited into
;; a number of other files.

;;; Code:

;; Add current directory to load-path
(add-to-list 'load-path (file-name-directory (or load-file-name buffer-file-name)))

;; Require configs
(require 'init-packages)
(require 'init-mode-line-light)
(require 'init-activities)
(require 'init-evil)
(require 'init-shell-u)
(require 'init-ts-fold)
(require 'init-typescript-u)
(require 'init-develop)
(require 'init-window-u)
;;(require 'init-company)
(require 'init-chinese-anniversary)
(require 'init-key-u)
(require 'init-ai)
(require 'init-vue)
(require 'init-org-rank)
(require 'init-theme)
(provide 'init-u)

;;(setq custom-file "~/.emacs.d/custom.el")
;;(load custom-file)

;;; init-u.el ends here

