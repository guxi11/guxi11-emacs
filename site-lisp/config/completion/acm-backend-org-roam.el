;;; acm-backend-org-roam.el -*- lexical-binding: t; no-byte-compile: t; -*-

;; org-roam v2 backend for ACM — 覆盖 lsp-bridge 内置的 v1 版本
;; 支持空格分词模糊匹配

(defgroup acm-backend-org-roam nil
  "Org roam backend for acm."
  :group 'acm)

(defcustom acm-enable-org-roam nil
  "Popup Org roam completions when this option is turn on."
  :type 'boolean
  :group 'acm-backend-org-roam)

(defcustom acm-backend-org-roam-candidates-number 10
  "Maximal number of Org roam candidate of menu."
  :type 'integer
  :group 'acm-backend-org-roam)

(defun acm-backend-org-roam--multi-word-match-p (keyword title)
  "KEYWORD 按空格拆词，每个词都必须在 TITLE 中模糊匹配到。"
  (let ((words (split-string keyword " " t))
        (down-title (downcase title)))
    (cl-every (lambda (word)
                (string-match-p (regexp-quote (downcase word)) down-title))
              words)))

(defun acm-backend-org-roam-candidates (keyword)
  (when (and acm-enable-org-roam
             (featurep 'org-roam)
             (derived-mode-p 'org-mode)
             (not (string-empty-p keyword)))
    (let* ((nodes (org-roam-node-list))
           (match-nodes (seq-filter
                         (lambda (node)
                           (acm-backend-org-roam--multi-word-match-p
                            keyword (org-roam-node-title node)))
                         nodes)))
      (mapcar
       (lambda (node)
         (let ((title (org-roam-node-title node))
               (id (org-roam-node-id node)))
           (list :key id
                 :icon "note"
                 :label title
                 :displayLabel title
                 :annotation "Org roam"
                 :backend "org-roam"
                 :id id)))
       (cl-subseq match-nodes 0 (min (length match-nodes) acm-backend-org-roam-candidates-number))))))

(defun acm-backend-org-roam-candidate-expand (candidate-info bound-start)
  "Insert an org-roam v2 id link for the selected candidate."
  (delete-region (line-beginning-position) (point))
  (let ((id (plist-get candidate-info :id))
        (title (plist-get candidate-info :label)))
    (insert (format "[[id:%s][%s]]" id title))))

(provide 'acm-backend-org-roam)

;;; acm-backend-org-roam.el ends here
