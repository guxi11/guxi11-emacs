;;; init-lsp-bridge.el --- Configuration for lsp-bridge

;; Filename: init-lsp-bridge.el
;; Description: Configuration for display line number
;; Author: Andy Stewart <lazycat.manatee@gmail.com>
;; Maintainer: Andy Stewart <lazycat.manatee@gmail.com>
;; Copyright (C) 2018, Andy Stewart, all rights reserved.
;; Created: 2018-08-26 02:03:32
;; Version: 0.1
;; Last-Updated: 2018-08-26 02:03:32
;;           By: Andy Stewart
;; URL: http://www.emacswiki.org/emacs/download/init-lsp-bridge.el
;; Keywords:
;; Compatibility: GNU Emacs 27.0.50
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
;; Configuration for display line number
;;

;;; Installation:
;;
;; Put init-lsp-bridge.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'init-lsp-bridge)
;;
;; No need more.

;;; Customize:
;;
;;
;;
;; All of the above can customize by:
;;      M-x customize-group RET init-lsp-bridge RET
;;

;;; Change log:
;;
;; 2018/08/26
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
;; 在 lsp-bridge 加载前先 load 我们的 v2 覆盖版本，
;; 这样 lsp-bridge 内部 (require 'acm-backend-org-roam) 时 feature 已存在，会跳过上游 v1。
(let ((our-file (expand-file-name "acm-backend-org-roam" (file-name-directory load-file-name))))
  (message "[acm-org-roam] loading v2 override from: %s" our-file)
  (load our-file))
(require 'lsp-bridge)
(require 'lsp-bridge-jdtls)

;; acm-update-candidates 里 org-roam 后端被 acm-in-roam-bracket-p 守卫，
;; 必须在 [[ 里面才触发。用 advice 让 org-mode 下无条件注入 org-roam 候选。
;; keyword 用行首到光标的文本，支持空格分词模糊匹配。

(defvar my/acm-org-roam-keyword ""
  "当前 org-roam 补全使用的完整 keyword（含空格）。")

(defun my/acm-org-roam-get-line-keyword ()
  "取当前行行首到光标的全部文本作为 keyword。"
  (buffer-substring-no-properties (line-beginning-position) (point)))

(defun my/acm-inject-org-roam-candidates (orig-fn)
  "Advice: 在 org-mode 下始终把 org-roam 候选混入补全结果。"
  (let ((result (funcall orig-fn)))
    (when (and acm-enable-org-roam
               (derived-mode-p 'org-mode)
               (featurep 'org-roam))
      (let* ((keyword (my/acm-org-roam-get-line-keyword))
             (roam-candidates (acm-backend-org-roam-candidates keyword)))
        (setq my/acm-org-roam-keyword keyword)
        (when roam-candidates
          (setq result (append result roam-candidates)))))
    result))

(advice-add 'acm-update-candidates :around #'my/acm-inject-org-roam-candidates)

;;; Code:

(setq lsp-bridge-enable-completion-in-minibuffer t)
(setq lsp-bridge-signature-show-function 'lsp-bridge-signature-show-with-frame)
(setq lsp-bridge-enable-with-tramp t)
(setq lsp-bridge-enable-org-babel t)
(setq acm-enable-capf t)
(setq acm-enable-quick-access t)
(setq acm-backend-yas-match-by-trigger-keyword t)
(setq acm-enable-org-roam t)
(setq acm-backend-order '("template-first-part-candidates"
                          "mode-first-part-candidates"
                          "tabnine-candidates"
                          "copilot-candidates"
                          "codeium-candidates"
                          "template-second-part-candidates"
                          "mode-second-part-candidates"))
(setq acm-enable-tabnine nil)
(setq acm-enable-codeium nil)
(setq acm-enable-lsp-workspace-symbol t)
;; (setq lsp-bridge-enable-inlay-hint t) ;; hide hints
(setq lsp-bridge-semantic-tokens t)
(setq-default lsp-bridge-semantic-tokens-ignore-modifier-limit-types ["variable"])

(setq lsp-bridge-default-mode-hooks (delete 'markdown-mode-hook lsp-bridge-default-mode-hooks))

(global-lsp-bridge-mode)

(add-to-list 'lsp-bridge-multi-lang-server-extension-list '(("html") . "html_tailwindcss"))
(add-to-list 'lsp-bridge-multi-lang-server-extension-list '(("css") . "css_tailwindcss"))

(setq lsp-bridge-csharp-lsp-server "csharp-ls")
(setq lsp-bridge-nix-lsp-server "nil")

;; 打开日志，开发者才需要
;; (setq lsp-bridge-enable-log t)

(setq lsp-bridge-get-multi-lang-server-by-project
      (lambda (project-path filepath)
        ;; If typescript file include deno.land url, then use Deno LSP server.
        (save-excursion
          (when (string-equal (file-name-extension filepath) "ts")
            (dolist (buf (buffer-list))
              (when (string-equal (buffer-file-name buf) filepath)
                (with-current-buffer buf
                  (goto-char (point-min))
                  (when (search-forward-regexp (regexp-quote "from \"https://deno.land") nil t)
                    (return "deno")))))))))

;; Support jump to define of EAF root from EAF application directory.
(setq lsp-bridge-get-project-path-by-filepath
      (lambda (filepath)
        (when (string-prefix-p (expand-file-name "~/lazycat-emacs/site-lisp/extensions/emacs-application-framework/app") filepath)
          (expand-file-name "~/lazycat-emacs/site-lisp/extensions/emacs-application-framework/"))))

(provide 'init-lsp-bridge)

;;; init-lsp-bridge.el ends here
