;;; init-u.el --- Load the foll configuration
;;; Commentary:

;; This file bootstraps the configruation, which is divited into
;; a number of other files.

;;; Code:

(message "zyy 0")
;; Require configs
(message "zyy 1")
(require 'init-packages)
(message "zyy 2")
(require 'init-theme)
(require 'init-activities)
(require 'init-evil)
(require 'init-develop)
(require 'init-window-u)
;;(require 'init-company)
(require 'init-chinese-anniversary)

(message "zyy 3")

(provide 'init-u)

;;(setq custom-file "~/.emacs.d/custom.el")
;;(load custom-file)

;;; init-u.el ends here

