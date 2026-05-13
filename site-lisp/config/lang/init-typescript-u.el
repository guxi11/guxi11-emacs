;;; init-typescript-u.el --- TypeScript treesit customizations   -*- lexical-binding: t; -*-

;; Filename: init-typescript-u.el
;; Description: TypeScript treesit mode customizations
;; Author: guxi11
;; Created: 2025-12-27

;;; Commentary:
;;
;; Enable function call highlighting for TypeScript by activating Level 4 features.
;;
;; Emacs 30's typescript-ts-mode already has font-lock rules for call_expression,
;; but they are in the 'function' feature which is at Level 4 (not enabled by default).
;;
;; The feature levels are:
;;   Level 1: comment, declaration
;;   Level 2: keyword, string, escape-sequence
;;   Level 3: constant, expression, identifier, number, pattern, property (default)
;;   Level 4: operator, function, bracket, delimiter
;;
;; We enable Level 4 to activate the built-in function call highlighting.
;;

;;; Code:

;; Enable Level 4 font-lock features (includes 'function' feature)
;; This activates the built-in call_expression highlighting
(setq treesit-font-lock-level 4)

;; Alternative: You can also enable Level 4 only for TypeScript modes
;; (defun typescript-ts-mode-enable-all-features ()
;;   "Enable all font-lock features including function calls."
;;   (setq-local treesit-font-lock-level 4))
;;
;; (add-hook 'typescript-ts-mode-hook #'typescript-ts-mode-enable-all-features)
;; (add-hook 'tsx-ts-mode-hook #'typescript-ts-mode-enable-all-features)

(provide 'init-typescript-u)

;;; init-typescript-u.el ends here
