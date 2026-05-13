;;; init-icons.el --- Icon configuration  -*- lexical-binding: t; -*-

;;; Commentary:
;; Configuration for icons (nerd-svg-icons for GUI, nerd-icons as data dependency).

;;; Code:

(use-package all-the-icons)

(use-package nerd-icons
  :ensure t)

(provide 'init-icons)
;;; init-icons.el ends here
