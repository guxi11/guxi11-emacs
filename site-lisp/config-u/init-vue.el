;;; init-vue.el --- Vue configuration -*- lexical-binding: t -*-

;;; Commentary:
;;
;; Vue.js treesit-fold configuration for Emacs.
;;
;; == Architecture Overview ==
;;
;; Vue files contain three sections: <template>, <script>, <style>.
;; Each section uses different syntax, so we need multiple tree-sitter parsers:
;;   - vue parser: handles overall structure (template_element, script_element, etc.)
;;   - typescript parser: handles JavaScript/TypeScript code inside <script>
;;   - css parser: handles CSS rules inside <style>
;;
;; The challenge is that treesit-fold assumes single parser per buffer.
;; We solve this by:
;;   1. Creating all three parsers
;;   2. Configuring treesit-range-settings to route content to correct parser
;;   3. Overriding treesit-fold functions via advice to iterate all parsers
;;
;; == Key Functions ==
;;
;; - my/vue-get-fold-rules-for-lang: returns fold rules for a given language
;; - my/vue--collect-all-foldable-nodes: collects foldable nodes from all parsers
;; - my/vue--get-fold-range: gets fold range for a node using correct language rules
;;

;;; navigate to prev/next
;; 用户调用 treesit-fold-next
;;         ↓
;; my/vue--advice-fold-next (around advice)
;;         ↓
;;     是 Vue 文件？
;;        /       \
;;       是        否
;;        ↓         ↓
;;   Vue 多 parser  调用原函数
;;     逻辑        (正常 ts 行为)

;;; Code:

(use-package web-mode
  :ensure t
  :mode "\\.vue\\'"
  :config
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-script-padding 0)
  (setq web-mode-style-padding 0)
  (setq web-mode-block-padding 0)

  ;;; ============================================================
  ;;; Fold Rules Definition
  ;;; ============================================================

  (defvar my/vue-fold-rules
    '((template_element . treesit-fold-range-html)
      (script_element   . treesit-fold-range-html)
      (style_element    . treesit-fold-range-html)
      (element          . treesit-fold-range-html)
      (comment          . treesit-fold-range-html-comment))
    "Fold rules for Vue parser (HTML-like structure).")

  (defvar my/typescript-fold-rules
    '((function_declaration  . treesit-fold-range-seq)
      (arrow_function        . treesit-fold-range-seq)
      (class_declaration     . treesit-fold-range-seq)
      (class_body            . treesit-fold-range-seq)
      (method_definition     . treesit-fold-range-seq)
      (object                . treesit-fold-range-seq)
      (array                 . treesit-fold-range-seq)
      (statement_block       . treesit-fold-range-seq)
      (interface_declaration . treesit-fold-range-seq)
      (type_alias_declaration . treesit-fold-range-seq)
      (enum_declaration      . treesit-fold-range-seq)
      (enum_body             . treesit-fold-range-seq)
      (export_clause         . treesit-fold-range-seq)
      (named_imports         . treesit-fold-range-seq)
      (comment               . treesit-fold-range-block-comment))
    "Fold rules for TypeScript/JavaScript.")

  (defvar my/css-fold-rules
    '((rule_set . treesit-fold-range-seq)
      (block    . treesit-fold-range-seq)
      (comment  . treesit-fold-range-block-comment))
    "Fold rules for CSS.")

  (defun my/vue-get-fold-rules-for-lang (lang)
    "Return fold rules alist for language LANG."
    (pcase lang
      ('vue        my/vue-fold-rules)
      ('typescript my/typescript-fold-rules)
      ('javascript my/typescript-fold-rules)
      ('css        my/css-fold-rules)
      (_           nil)))

  ;;; ============================================================
  ;;; Predicate: Check if current buffer is a Vue file
  ;;; ============================================================

  (defun my/vue-file-p ()
    "Return non-nil if current buffer is a Vue file."
    (and (buffer-file-name)
         (string-equal "vue" (file-name-extension (buffer-file-name)))))

  ;;; ============================================================
  ;;; Core Helper Functions
  ;;; ============================================================

  (defun my/vue--get-fold-range (node)
    "Compute fold range (BEG . END) for NODE using Vue multi-parser rules."
    (when node
      (let* ((parser (treesit-node-parser node))
             (lang (treesit-parser-language parser))
             (rules (my/vue-get-fold-rules-for-lang lang))
             (node-type (intern (treesit-node-type node)))
             (fold-func (alist-get node-type rules)))
        (when fold-func
          (cond
           ((functionp fold-func)
            (funcall fold-func node (cons 0 0)))
           ((listp fold-func)
            (funcall (nth 0 fold-func) node (cons (nth 1 fold-func) (nth 2 fold-func))))
           (t nil))))))

  (defun my/vue--node-foldable-p (node)
    "Return non-nil if NODE can actually be folded."
    (when node
      (and (not (treesit-fold--node-range-on-same-line node))
           (my/vue--get-fold-range node))))

  (defun my/vue--collect-all-foldable-nodes ()
    "Collect all foldable nodes from all parsers in current buffer."
    (let ((all-nodes nil))
      (dolist (parser (treesit-parser-list))
        (let* ((lang (treesit-parser-language parser))
               (rules (my/vue-get-fold-rules-for-lang lang))
               (root (treesit-parser-root-node parser)))
          (when rules
            (let ((patterns (seq-mapcat (lambda (r) `((,(car r)) @name)) rules)))
              (condition-case nil
                  (let* ((query (treesit-query-compile lang patterns))
                         (captures (treesit-query-capture root query)))
                    (dolist (cap captures)
                      (let ((node (cdr cap)))
                        (when (my/vue--node-foldable-p node)
                          (push node all-nodes)))))
                (error nil))))))
      (sort all-nodes (lambda (a b)
                        (< (treesit-node-start a) (treesit-node-start b))))))

  ;;; ============================================================
  ;;; Advice Functions (with Vue file check)
  ;;; ============================================================

  (defun my/vue--advice-foldable-node-at-pos (orig-fn &optional pos)
    "Advice for `treesit-fold--foldable-node-at-pos'.
Only use Vue logic for Vue files, otherwise call ORIG-FN."
    (if (not (my/vue-file-p))
        (funcall orig-fn pos)
      ;; Vue file: search across all parsers
      (let* ((pos (or pos (point)))
             (result nil))
        (catch 'found
          (dolist (parser (treesit-parser-list))
            (let* ((lang (treesit-parser-language parser))
                   (rules (my/vue-get-fold-rules-for-lang lang))
                   (root (treesit-parser-root-node parser))
                   (node (treesit-node-descendant-for-range root pos pos))
                   (current node))
              (while current
                (when (my/vue--node-foldable-p current)
                  (setq result current)
                  (throw 'found result))
                (setq current (treesit-node-parent current))))))
        result)))

  (defun my/vue--advice-get-fold-range (orig-fn node)
    "Advice for `treesit-fold--get-fold-range'.
Only use Vue logic for Vue files, otherwise call ORIG-FN."
    (if (not (my/vue-file-p))
        (funcall orig-fn node)
      (my/vue--get-fold-range node)))

  (defun my/vue--advice-close-all (orig-fn)
    "Advice for `treesit-fold-close-all'.
Only use Vue logic for Vue files, otherwise call ORIG-FN."
    (if (not (my/vue-file-p))
        (funcall orig-fn)
      (treesit-fold--ensure-ts
        (let ((folded nil))
          (dolist (node (my/vue--collect-all-foldable-nodes))
            (when-let* ((range (my/vue--get-fold-range node))
                        (ov (treesit-fold--create-overlay range)))
              (setq folded t)))
          (when folded
            (run-hooks 'treesit-fold-on-fold-hook)
            t)))))

  (defun my/vue--advice-open-all (orig-fn)
    "Advice for `treesit-fold-open-all'.
Only use Vue logic for Vue files, otherwise call ORIG-FN."
    (if (not (my/vue-file-p))
        (funcall orig-fn)
      (treesit-fold--ensure-ts
        (when-let* ((overlays (treesit-fold--overlays-in 'invisible 'treesit-fold)))
          (mapc #'delete-overlay overlays)
          (run-hooks 'treesit-fold-on-fold-hook)
          t))))

  (defun my/vue--advice-fold-next (orig-fn &optional arg)
    "Advice for `treesit-fold-next'.
Only use Vue logic for Vue files, otherwise call ORIG-FN."
    (if (not (my/vue-file-p))
        (funcall orig-fn arg)
      (let* ((arg (or arg 1))
             (backward (< arg 0))
             (count (abs arg))
             (current-pos (point))
             (nodes (my/vue--collect-all-foldable-nodes))
             (target nil))
        (if backward
            (let ((before-nodes (seq-filter (lambda (n)
                                              (< (treesit-node-start n) current-pos))
                                            nodes)))
              (when (>= (length before-nodes) count)
                (setq target (nth (- (length before-nodes) count) before-nodes))))
          (let ((after-nodes (seq-filter (lambda (n)
                                           (> (treesit-node-start n) current-pos))
                                         nodes)))
            (when (>= (length after-nodes) count)
              (setq target (nth (1- count) after-nodes)))))
        (if target
            (goto-char (treesit-node-start target))
          (message "No %s foldable region" (if backward "previous" "next"))))))

  (defun my/vue--advice-fold-previous (orig-fn &optional arg)
    "Advice for `treesit-fold-previous'.
Only use Vue logic for Vue files, otherwise call ORIG-FN."
    (if (not (my/vue-file-p))
        (funcall orig-fn arg)
      (my/vue--advice-fold-next nil (- (or arg 1)))))

  ;;; ============================================================
  ;;; Setup and Teardown
  ;;; ============================================================

  (defun my/setup-vue-treesit ()
    "Setup tree-sitter parsers and folding for Vue files."
    (when (my/vue-file-p)
      (when (and (fboundp 'treesit-parser-create)
                 (treesit-language-available-p 'vue))

        ;; Step 1: Create parsers
        (treesit-parser-create 'vue)
        (when (treesit-language-available-p 'typescript)
          (treesit-parser-create 'typescript))
        (when (treesit-language-available-p 'css)
          (treesit-parser-create 'css))

        ;; Step 2: Configure range settings
        (setq-local treesit-range-settings
                    (treesit-range-rules
                     :embed 'typescript
                     :host 'vue
                     '((script_element (raw_text) @cap))
                     :embed 'css
                     :host 'vue
                     '((style_element (raw_text) @cap))))
        (treesit-update-ranges)

        ;; Step 3: Setup treesit-fold with advice (using :around)
        (when (require 'treesit-fold nil t)
          (setq-local treesit-fold-range-alist
                      `((web-mode . ,my/vue-fold-rules)))

          ;; Add advice only once (check if already added)
          (unless (advice-member-p #'my/vue--advice-foldable-node-at-pos
                                   'treesit-fold--foldable-node-at-pos)
            (advice-add 'treesit-fold--foldable-node-at-pos
                        :around #'my/vue--advice-foldable-node-at-pos)
            (advice-add 'treesit-fold--get-fold-range
                        :around #'my/vue--advice-get-fold-range)
            (advice-add 'treesit-fold-close-all
                        :around #'my/vue--advice-close-all)
            (advice-add 'treesit-fold-open-all
                        :around #'my/vue--advice-open-all)
            (advice-add 'treesit-fold-next
                        :around #'my/vue--advice-fold-next)
            (advice-add 'treesit-fold-previous
                        :around #'my/vue--advice-fold-previous))

          (treesit-fold-mode 1)))))

  (add-hook 'web-mode-hook #'my/setup-vue-treesit))

(provide 'init-vue)

;;; init-vue.el ends here
