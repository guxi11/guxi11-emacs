;;; init-org.el --- Configure for org-mode

;; Filename: init-org.el
;; Description: Configure for org-mode
;; Author: Andy Stewart <lazycat.manatee@gmail.com>
;; Maintainer: Andy Stewart <lazycat.manatee@gmail.com>
;; Copyright (C) 2020, Andy Stewart, all rights reserved.
;; Created: 2020-03-31 22:32:49
;; Version: 0.1
;; Last-Updated: 2020-03-31 22:32:49
;;           By: Andy Stewart
;; URL: http://www.emacswiki.org/emacs/download/init-org.el
;; Keywords:
;; Compatibility: GNU Emacs 28.0.50
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
;; Configure for org-mode
;;

;;; Installation:
;;
;; Put init-org.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'init-org)
;;
;; No need more.

;;; Customize:
;;
;;
;;
;; All of the above can customize by:
;;      M-x customize-group RET init-org RET
;;

;;; Change log:
;;
;; 2020/03/31
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

(setq-default ispell-program-name nil)

(require 'init-chinese-anniversary)

(setq org-directory (file-truename "~/org/"))
(setq org-agenda-files '("~/org/tencent/" "~/org/roam/journal/capture.org" "~/org/roam/journal/DaysMatter.org" "~/org/refile.org"))
;; (setq org-agenda-files '("~/org/tencent/" "~/org/roam/journal/capture.org" "~/org/refile.org"))
;;(setq org-agenda-files (directory-files-recursively "~/org/" ".org$"))
(setq pv/org-refile-file (concat org-directory "refile.org"))


(defun pv/init-org-hook ()
  (setq truncate-lines nil)
  (org-toggle-pretty-entities) ; display LaTeX symbols
  )

(setq org-format-latex-options
      (plist-put org-format-latex-options :scale 1.4)) ; 放大2倍

(defun pv/org-skip-subtree-if-priority (priority)
  "Skip an agenda subtree if it has a priority of PRIORITY.
PRIORITY may be one of the characters ?A, ?B, or ?C."
  (let ((subtree-end (save-excursion (org-end-of-subtree t)))
        (pri-value (* 1000 (- org-lowest-priority priority)))
        (pri-current (org-get-priority (thing-at-point 'line t))))
    (if (= pri-value pri-current)
        subtree-end
      nil)))
(defun pv/org-skip-subtree-if-habit ()
  "Skip an agenda entry if it has a STYLE property equal to \"habit\"."
  (let ((subtree-end (save-excursion (org-end-of-subtree t))))
    (if (string= (org-entry-get nil "STYLE") "habit")
        subtree-end
      nil)))
;;(org-hide-leading-stars t "clearer way to display")

(setq org-display-remote-inline-images 'download) ;; Emacs 29+
(setq org-startup-with-inline-images t) ;; "always display inline image"
(setq org-image-actual-width 600) ;; "set width of image when displaying"
(setq org-outline-path-complete-in-steps nil)
(setq org-todo-keywords
      (quote ((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)")
              (sequence "WAITING(w@/!)" "|" "CANCELLED(c@/!)" "MEETING"))))
(setq org-todo-keyword-faces
      (quote (("TODO" :foreground "goldenrod1" :weight bold)
              ("NEXT" :foreground "DodgerBlue1" :weight bold)
              ("DONE" :foreground "SpringGreen2" :weight bold)
              ("WAITING" :foreground "LightSalmon1" :weight bold)
              ("CANCELLED" :foreground "LavenderBlush4" :weight bold)
              ("MEETING" :foreground "IndianRed1" :weight bold))))
(setq org-todo-state-tags-triggers
      (quote (("CANCELLED" ("CANCELLED" . t))
              ("WAITING" ("WAITING" . t))
              (done ("WAITING"))
              ("TODO" ("WAITING") ("CANCELLED"))
              ("NEXT" ("WAITING") ("CANCELLED"))
              ("DONE" ("WAITING") ("CANCELLED")))))
(setq org-adapt-indentation t)
;; Do not dim blocked tasks
(setq org-agenda-dim-blocked-tasks nil)
;; compact the block agenda view
(setq org-agenda-compact-blocks t)
(setq org-agenda-span 9)
(setq org-agenda-start-day "0d")
(setq org-agenda-start-on-weekday nil)
(setq org-agenda-tags-column -65) ; default value auto has issues
;; Custom agenda command definitions
(setq org-agenda-custom-commands
      (quote (("d" "Daily agenda and all TODOs"
               ((tags "PRIORITY=\"A\""
                      ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                       (org-agenda-overriding-header "High-priority unfinished tasks:")))
                (agenda "" ((org-agenda-ndays 3)))
                (alltodo ""
                         ((org-agenda-skip-function '(or (pv/org-skip-subtree-if-habit)
                                                         (pv/org-skip-subtree-if-priority ?A)
                                                         (org-agenda-skip-if nil '(scheduled deadline))))
                          (org-agenda-overriding-header "ALL normal priority tasks:"))))
               ((org-agenda-compact-blocks t)))
	          )))
(setq org-capture-templates
      (quote (("t" "todo" entry (file pv/org-refile-file)
               "* TODO %?\n%U\n%a\n" :clock-in t :clock-resume t)
              ("r" "respond" entry (file pv/org-refile-file)
               "* NEXT Respond to %:from on %:subject\nSCHEDULED: %t\n%U\n%a\n" :clock-in t :clock-resume t :immediate-finish t)
              ("n" "note" entry (file pv/org-refile-file)
               "* %? :NOTE:\n%U\n%a\n" :clock-in t :clock-resume t)
              ("w" "org-protocol" entry (file pv/org-refile-file)
               "* TODO Review %c\n%U\n" :immediate-finish t)
              ("m" "Meeting" entry (file pv/org-refile-file)
               "* MEETING with %? :MEETING:\n%U" :clock-in t :clock-resume t))))
(setq org-refile-targets (quote ((nil :maxlevel . 9)
                                 (org-agenda-files :maxlevel . 9))))
;; Use full outline paths for refile targets - we file directly with IDO
(setq org-refile-use-outline-path 'file)

(custom-set-variables
 '(org-agenda-prefix-format
   '((agenda . " %i %-12:c%?-8t% s")
	 (todo . " %i %-12:c")
	 (tags . " %i %-12:c")
	 (search . " %i %-12:c")))
 '(org-agenda-scheduled-leaders '("Sched: " "S.%2dx: "))
 '(org-agenda-deadline-leaders '("Deadl: " "D in%2d:" "D.%2dx: "))
 '(org-agenda-time-grid
   '((daily today require-timed)
	 (800 1000 1200 1400 1600 1800 2000)
	 ".." "----------------"))
 )

(with-eval-after-load 'org
  (setq org-odt-preferred-output-format "docx") ;ODT转换格式默认为docx
  (setq org-startup-folded nil)                 ;默认展开内容
  (setq org-startup-indented t)                 ;默认缩进内容

  ;; 隐藏 HTML 导出文件底部的一些无用信息
  (setq org-export-with-author nil)
  (setq org-export-time-stamp-file nil)
  (setq org-html-validation-link nil)

  (defun org-export-docx ()
    (interactive)
    (let ((docx-file (concat (file-name-sans-extension (buffer-file-name)) ".docx"))
          (template-file (concat (file-name-as-directory lazycat-emacs-root-dir)
                                 (file-name-as-directory "template")
                                 "template.docx")))
      (shell-command (format "pandoc %s -o %s --reference-doc=%s"
                             (buffer-file-name)
                             docx-file
                             template-file
                             ))
      (message "Convert finish: %s" docx-file))))

(dolist (hook (list
               'org-mode-hook
               ))
  (add-hook hook #'(lambda ()
                     (require 'eaf)

                     (setq truncate-lines nil) ;默认换行

                     (lazy-load-set-keys
                      '(
                        ("M-h" . set-mark-command) ;选中激活
                        ("C-c C-o" . eaf-open-url-at-point)
                        )
                      org-mode-map)

                     (require 'valign)
                     (valign-mode)
                     )))

(setq org-roam-v2-ack t)
(setq org-roam-directory "~/org/roam")
(setq org-roam-capture-templates
      '(("d" "default" plain
         "%?"
         :if-new (file+head "${slug}.org" "#+created: %<%Y/%m/%d-%H:%M>\n#+title: ${title}\n")
         :unnarrowed t)))
(setq org-roam-dailies-directory "journal/")
(setq org-roam-completion-everywhere t)
(require 'org-roam-dailies)
(org-roam-db-autosync-mode)

;; immediate create
(defun org-roam-node-insert-immediate (arg &rest args)
  (interactive "P")
  (let ((args (cons arg args))
        (org-roam-capture-templates (list (append (car org-roam-capture-templates)
                                                  '(:immediate-finish t)))))
    (apply #'org-roam-node-insert args)))

(require 'org-roam-node)

(defun my/org-roam-filter-by-tag (tag-name)
  (lambda (node)
    (member tag-name (org-roam-node-tags node))))

(defun my/org-roam-list-notes-by-tag (tag-name)
  (mapcar #'org-roam-node-file
          (seq-filter
           (my/org-roam-filter-by-tag tag-name)
           (org-roam-node-list))))

(defun my/org-roam-refresh-agenda-list ()
  (interactive)
  (setq org-agenda-files (cl-union
;; '("~/org/tencent/" "~/org/roam/journal/capture.org" "~/org/refile.org")
'("~/org/tencent/" "~/org/roam/journal/capture.org" "~/org/roam/journal/DaysMatter.org" "~/org/refile.org")
                          (my/org-roam-list-notes-by-tag "todo"))))

;; Build the agenda list the first time for the session
(my/org-roam-refresh-agenda-list)

(provide 'init-org)

;;; init-org.el ends here
