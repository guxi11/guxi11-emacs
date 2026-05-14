;;; init.el --- Unified entry point for guxi11-emacs -*- lexical-binding: t; -*-
;;; Code:

;; Add all config subdirectories to load-path
(dolist (subdir '("core" "editor" "completion" "lang" "ui" "tools" "doc"))
  (add-to-list 'load-path
               (expand-file-name subdir (file-name-directory (or load-file-name buffer-file-name)))))

;; ============================================================
;; Core - startup acceleration, generic settings, font, packages
;; ============================================================
(require 'init-accelerate)
(require 'init-font)

(let ((gc-cons-threshold most-positive-fixnum)
      (gc-cons-percentage 0.6)
      (file-name-handler-alist nil))

  (setq frame-inhibit-implied-resize t)
  (setq-default inhibit-redisplay t
                inhibit-message t)
  (add-hook 'window-setup-hook
            (lambda ()
              (setq-default inhibit-redisplay nil
                            inhibit-message nil)
              (redisplay)))

  (defvar lazycat-emacs-root-dir (file-truename "~/guxi11-emacs/site-lisp"))
  (defvar lazycat-emacs-config-dir (concat lazycat-emacs-root-dir "/config"))
  (defvar lazycat-emacs-extension-dir (concat lazycat-emacs-root-dir "/extensions"))

  (with-temp-message ""

    ;; Core
    (require 'init-generic)
    (require 'lazy-load)
    (require 'display-line-numbers)
    (require 'basic-toolkit)
    (require 'redo)
    (require 'init-packages)

    ;; ============================================================
    ;; Editor - keybindings, evil, indentation, auto-save, etc.
    ;; ============================================================
    (require 'init-highlight-parentheses)
    (require 'init-line-number)
    (require 'init-auto-save)
    (require 'init-mode)
    (require 'init-indent)
    (require 'init-key)
    (require 'init-key-u)
    (require 'init-evil)

    ;; ============================================================
    ;; UI - theme, mode-line, icons, windows, activities
    ;; ============================================================
    (require 'init-mode-line-light)
    (require 'init-activities)
    (require 'init-window-u)
    (require 'init-theme)

    ;; org-roam DB sync blocks regardless — run at startup so user never sees mid-session freeze
    (require 'init-chinese-anniversary)
    (require 'init-org-rank)
    (require 'init-org)

    ;; ============================================================
    ;; Deferred - truly non-blocking, safe to lazy-load
    ;; ============================================================
    (run-with-idle-timer
     1 nil
     #'(lambda ()
         (require 'pretty-lambdada)
         (require 'browse-kill-ring)
         (require 'elf-mode)
         (require 'init-eldoc)
         (require 'init-yasnippet)
         (require 'init-shell-u)
         (require 'init-develop)
         (require 'init-eww)
         (require 'init-olivetti)))

    (run-with-idle-timer
     2 nil
     #'(lambda ()
         (require 'init-lsp-bridge)
         (require 'init-treesit)
         (require 'init-ts-fold)
         (require 'init-typescript-u)
         (require 'init-vue)
         (require 'init-css-mode-u)
         (message "-- hi (startup: %s)" (emacs-init-time))))))

(provide 'init)
;;; init.el ends here
