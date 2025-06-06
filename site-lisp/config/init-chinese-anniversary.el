;;; chinese-anniversary -- Summary
;; Chinese anniversary

;;; Commentary:

;;; Code:

(defun my-diary-chinese-anniversary (lunar-month lunar-day &optional year mark)
  (if year
      (let* ((d-date (diary-make-date lunar-month lunar-day year))
             (a-date (calendar-absolute-from-gregorian d-date))
             (c-date (calendar-chinese-from-absolute a-date))
             (cycle (car c-date))
             (yy (cadr c-date))
             (y (+ (* 100 cycle) yy)))
        (diary-chinese-anniversary lunar-month lunar-day y mark))
    (diary-chinese-anniversary lunar-month lunar-day year mark)))

(provide 'chinese-anniversary)
;;; chinese-anniversary.el ends here
