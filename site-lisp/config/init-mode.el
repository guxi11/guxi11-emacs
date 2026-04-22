;;; init-mode.el --- File mode setup

;; Filename: init-mode.el
;; Description: File mode setup
;; Author: Andy Stewart <andy@freedom>
;; Maintainer: Andy Stewart <andy@freedom>
;; Copyright (C) 2013, Andy Stewart, all rights reserved.
;; Created: 2013-12-28 08:55:04
;; Version: 0.1
;; Last-Updated: 2013-12-28 08:55:04
;;           By: Andy Stewart
;; URL: http://www.emacswiki.org/emacs/download/init-mode.el
;; Keywords:
;; Compatibility: GNU Emacs 24.3.50.1
;;
;; Features that might be required by this library:
;;
;;
;;

;;; This file is NOT part of GNU Emacs

;;; License
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.

;;; Commentary:
;;
;; File mode setup
;;

;;; Installation:
;;
;; Put init-mode.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'init-mode)
;;
;; No need more.

;;; Customize:
;;
;;
;;
;; All of the above can customize by:
;;      M-x customize-group RET init-mode RET
;;

;;; Change log:
;;
;; 2013/12/28
;;      * First released.
;;

;;; Acknowledgements:
;;
;;
;;

;;; TODO
;;
;;
;;

;;; Require

;;; Code:

;;; ### auto-mode-alist ###
;;; --- 绑定扩展名到特定的模式
(defun add-to-alist (alist-var elt-cons &optional no-replace)
  "Add to the value of ALIST-VAR an element ELT-CONS if it isn't there yet.
If an element with the same car as the car of ELT-CONS is already present,
replace it with ELT-CONS unless NO-REPLACE is non-nil; if a matching
element is not already present, add ELT-CONS to the front of the alist.
The test for presence of the car of ELT-CONS is done with `equal'."
  (let ((existing-element (assoc (car elt-cons) (symbol-value alist-var))))
    (if existing-element
        (or no-replace
            (rplacd existing-element (cdr elt-cons)))
      (set alist-var (cons elt-cons (symbol-value alist-var)))))
  (symbol-value alist-var))

(dolist (elt-cons '(
                    ("\\.markdown" . markdown-mode)
                    ("\\.md" . markdown-mode)
                    ("\\.stumpwmrc\\'" . lisp-mode)
                    ("\\.inc\\'" . asm-mode)
                    ("\\.max\\'" . maxima-mode)
                    ("\\.org\\'" . org-mode)
                    ("\\.cron\\(tab\\)?\\'" . crontab-mode)
                    ("cron\\(tab\\)?\\." . crontab-mode)
                    ("\\.a90\\'" . intel-hex-mode)
                    ("\\.hex\\'" . intel-hex-mode)
                    ("\\.py$" . python-mode)
                    ("SConstruct". python-mode)
                    ("\\.jl\\'" . lisp-mode)
                    ("\\.asdf\\'" . lisp-mode)
                    ("CMakeLists\\.txt\\'" . cmake-mode)
                    ("\\.cmake\\'" . cmake-mode)
                    ("\\.vue" . web-mode)
                    ("\\.wxml" . web-mode)
                    ("\\.phtml\\'" . web-mode)
                    ("\\.jsp\\'" . web-mode)
                    ("\\.as[cp]x\\'" . web-mode)
                    ("\\.erb\\'" . web-mode)
                    ("\\.mustache\\'" . web-mode)
                    ("\\.djhtml\\'" . web-mode)
                    ("\\.html?\\'" . web-mode)
                    ("\\.js.erb\\'" . js-mode)
                    ("\\.css\\'" . css-mode)
                    ("\\.wxss\\'" . css-mode)
                    ("\\.js$" . js-mode)
                    ("\\.wxs$" . js-mode)
                    ("\\.jsx$" . web-mode)
                    ("\\.pdf$" . pdf-view-mode)
                    ("\\.ts$" . typescript-ts-mode)
                    ("\\.tsx$" . typescript-ts-mode)
                    ("\\.mts$" . typescript-ts-mode)
                    ("\\.cpp$" . c++-mode)
                    ("\\.h$" . c++-mode)
                    ("\\.bc$" . hexl-mode)
                    ("\\.json$" . json-mode)
                    ))
  (add-to-alist 'auto-mode-alist elt-cons))



;;; Mode load.
(autoload 'cmake-mode "cmake-mode")
(autoload 'markdown-mode "init-markdown-mode")
(autoload 'web-mode "init-web-mode")
(autoload 'css-mode "init-css-mode")
(autoload 'python-mode "init-python")
(autoload 'js-mode "init-web-mode")
(autoload 'typescript-mode "typescript-mode")
(autoload 'json-mode "json-mode")

;;; ### Auto-fill ###
;;; --- 自动换行
(setq default-fill-column 100)          ;默认显示 100列就换行
(dolist (hook (list
               'after-text-mode-hook
               'message-mode-hook
               ))
  (add-hook hook #'(lambda () (auto-fill-mode 1))))

(provide 'init-mode)

;;; init-mode.el ends here
