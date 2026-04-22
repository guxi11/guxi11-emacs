;;; init-key-u

;; 自定义两个函数
;; Faster move cursor
(defun next-ten-lines()
  "Move cursor to next 10 lines."
  (interactive)
  (next-line 10))

(defun previous-ten-lines()
  "Move cursor to previous 10 lines."
  (interactive)
  (previous-line 10))
;; 绑定到快捷键

(global-set-key (kbd "M-n") 'next-ten-lines)            ; 光标向下移动 10 行
(global-set-key (kbd "M-p") 'previous-ten-lines)        ; 光标向上移动 10 行

(global-set-key (kbd "RET") 'newline-and-indent)

(global-set-key (kbd "s-b") 'previous-buffer)
(global-set-key (kbd "s-z") 'zoom-window-zoom)
(global-set-key (kbd "M-v") 'yank) ;; overwrite scroll up
(global-set-key (kbd "C-c C-o") 'org-open-at-point)

;;(define-key global-map (kbd "C-c") (make-sparse-keymap)) ; https://emacs.stackexchange.com/a/54792
;; (global-set-key (kbd "C-c ;") 'comment-or-uncomment-region) ; 为选中的代码加注释/去注释

(provide 'init-key-u)

;; init-key-u ends here
