;;; init-u.el --- Load the foll configuration
;;; Commentary:

;; This file bootstraps the configruation, which is divited into
;; a number of other files.

;;; Code:

;; Require configs
(require 'init-mode-line)
(require 'init-packages)
(require 'init-theme)
(require 'init-activities)
(require 'init-evil)
(require 'init-develop)
(require 'init-window-u)
;;(require 'init-company)
(require 'init-chinese-anniversary)
(require 'init-key-u)
(provide 'init-u)

;;(setq custom-file "~/.emacs.d/custom.el")
;;(load custom-file)

;;; init-u.el ends here

