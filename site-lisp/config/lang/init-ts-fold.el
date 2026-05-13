;;; init-ts-fold.el --- treesit-fold configuration for built-in tree-sitter modes

;;; Commentary:
;; treesit-fold provides code folding based on Emacs 29+ built-in treesit.
;; It works better than hs-minor-mode for tree-sitter enabled modes.

;;; Code:

(use-package treesit-fold
  :load-path "~/guxi11-emacs/site-lisp/extensions/treesit-fold"
  :commands (treesit-fold-close
             treesit-fold-open
             treesit-fold-open-recursively
             treesit-fold-close-all
             treesit-fold-open-all
             treesit-fold-toggle)
  :hook ((tsx-ts-mode . treesit-fold-mode)
         (typescript-ts-mode . treesit-fold-mode)
         (js-ts-mode . treesit-fold-mode)
         (json-ts-mode . treesit-fold-mode)
         (css-ts-mode . treesit-fold-mode)
         (html-ts-mode . treesit-fold-mode)
         (python-ts-mode . treesit-fold-mode)
         (rust-ts-mode . treesit-fold-mode)
         (go-ts-mode . treesit-fold-mode)
         (c-ts-mode . treesit-fold-mode)
         (c++-ts-mode . treesit-fold-mode)
         (java-ts-mode . treesit-fold-mode))
  :config
  ;; Optional: enable fold indicators in the fringe
  ;; (global-treesit-fold-indicators-mode 1)

  ;; Custom functions to navigate between foldable regions
  (defun treesit-fold-next (&optional arg)
    "Move to the next foldable region.
With prefix ARG, move forward ARG foldable regions."
    (interactive "p")
    (unless (treesit-fold-ready-p)
      (user-error "No tree-sitter parser in current buffer"))
    (let* ((arg (or arg 1))
           (backward (< arg 0))
           (count (abs arg))
           (mode-ranges (alist-get major-mode treesit-fold-range-alist))
           (root (treesit-buffer-root-node))
           (patterns (seq-mapcat (lambda (fold-range) `((,(car fold-range)) @name))
                                 mode-ranges))
           (query (treesit-query-compile (treesit-node-language root) patterns))
           (all-nodes (treesit-query-capture root query))
           ;; Filter nodes that are actually foldable (not on same line)
           (foldable-nodes (cl-remove-if
                            (lambda (n)
                              (treesit-fold--node-range-on-same-line (cdr n)))
                            all-nodes))
           ;; Sort by position
           (sorted-nodes (sort foldable-nodes
                               (lambda (a b)
                                 (< (treesit-node-start (cdr a))
                                    (treesit-node-start (cdr b))))))
           (current-pos (point))
           (target-node nil)
           (found 0))
      (if backward
          ;; Find previous foldable region
          (dolist (node (reverse sorted-nodes))
            (when (and (< found count)
                       (< (treesit-node-start (cdr node)) current-pos))
              (setq target-node (cdr node))
              (cl-incf found)))
        ;; Find next foldable region
        (dolist (node sorted-nodes)
          (when (and (< found count)
                     (> (treesit-node-start (cdr node)) current-pos))
            (when (= found 0)
              (setq target-node (cdr node)))
            (cl-incf found)
            (when (= found count)
              (setq target-node (cdr node))))))
      (if target-node
          (goto-char (treesit-node-start target-node))
        (message "No %s foldable region" (if backward "previous" "next")))))

  (defun treesit-fold-previous (&optional arg)
    "Move to the previous foldable region.
With prefix ARG, move backward ARG foldable regions."
    (interactive "p")
    (treesit-fold-next (- (or arg 1)))))

(provide 'init-ts-fold)

;;; init-ts-fold.el ends here
