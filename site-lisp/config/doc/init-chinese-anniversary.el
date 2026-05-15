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

(provide 'init-chinese-anniversary)
;;; init-chinese-anniversary.el ends here
