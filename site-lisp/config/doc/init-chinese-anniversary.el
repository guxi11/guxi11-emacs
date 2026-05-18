;;; init-chinese-anniversary -- Summary
;; Chinese anniversary

;;; Commentary:

;;; Code:

(defun org-chinese-anniversary (lunar-month lunar-day &optional year mark)
  "Like `diary-chinese-anniversary' but with org- prefix so org-agenda
treats the entry text safely (no sexp-read on trailing text)."
  (if year
      (let* ((d-date (diary-make-date lunar-month lunar-day year))
             (a-date (calendar-absolute-from-gregorian d-date))
             (c-date (calendar-chinese-from-absolute a-date))
             (cycle (car c-date))
             (yy (cadr c-date))
             (y (+ (* 100 cycle) yy)))
        (diary-chinese-anniversary lunar-month lunar-day y mark))
    (diary-chinese-anniversary lunar-month lunar-day year mark)))

;; backward compat alias
(defalias 'my-diary-chinese-anniversary 'org-chinese-anniversary)

;; org-diary-sexp-entry constructs (let ((entry %s)(date ...)) SEXP) via
;; format %s — multi-word entry text becomes multiple symbols in the binding,
;; breaking eval. Fix: when entry has spaces, eval with proper quoting.
(defun my/fix-org-diary-sexp-entry (orig-fn sexp entry date)
  "Bypass orig-fn for multi-word entries that break unquoted let bindings."
  (let ((entry-str (substring-no-properties (if (stringp entry) entry ""))))
    (if (string-match-p " " entry-str)
        (condition-case nil
            (let* ((sexp-str (substring-no-properties (if (stringp sexp) sexp "")))
                   (sexp-form (car (read-from-string sexp-str)))
                   (result (eval `(let ((entry ,entry-str) (date ',date)) ,sexp-form))))
              (cond ((stringp result) result)
                    (result entry-str)))
          (error nil))
      (funcall orig-fn sexp entry date))))


(defun my/install-diary-sexp-fix ()
  "Install advice on org-diary-sexp-entry if available and not yet advised."
  (when (and (fboundp 'org-diary-sexp-entry)
             (not (advice-member-p #'my/fix-org-diary-sexp-entry 'org-diary-sexp-entry)))
    (advice-add 'org-diary-sexp-entry :around #'my/fix-org-diary-sexp-entry)))

;; Try all possible load timings
(my/install-diary-sexp-fix)
(with-eval-after-load 'org (my/install-diary-sexp-fix))
(with-eval-after-load 'org-agenda (my/install-diary-sexp-fix))

(provide 'init-chinese-anniversary)
;;; init-chinese-anniversary.el ends here
