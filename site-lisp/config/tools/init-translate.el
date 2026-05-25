;;; init-translate.el --- lightweight Youdao translate -*- lexical-binding: t; -*-

(require 'json)

(defvar yd-translate-lang-detect-threshold 0.5)

(defun yd--chinese-p (text)
  "Return t if TEXT is mostly Chinese."
  (let ((cn 0) (total (length text)))
    (dotimes (i total)
      (when (> (aref text i) #x4e00)
        (cl-incf cn)))
    (> (/ (float cn) (max total 1)) yd-translate-lang-detect-threshold)))

(defun yd--query (word)
  "Query Youdao suggest API for WORD, return translation string."
  (let* ((lang (if (yd--chinese-p word) "zh" "en"))
         (url (format "https://dict.youdao.com/suggest?q=%s&le=%s&num=8&doctype=json"
                      (url-hexify-string word) lang))
         (output (shell-command-to-string (format "curl -s '%s'" url)))
         (json (json-read-from-string output))
         (entries (cdr (assq 'entries (cdr (assq 'data json))))))
    (if entries
        (mapconcat (lambda (e)
                     (let ((entry (cdr (assq 'entry e)))
                           (explain (cdr (assq 'explain e))))
                       (if explain
                           (format "%s  %s" entry explain)
                         entry)))
                   entries "\n")
      "No result")))

;;;###autoload
(defun yd-translate-at-point ()
  "Translate word at point with Youdao, show in minibuffer."
  (interactive)
  (let* ((word (or (and (use-region-p)
                        (buffer-substring-no-properties (region-beginning) (region-end)))
                   (thing-at-point 'word t)))
         (result (yd--query word)))
    (message "%s" result)))

;;;###autoload
(defun yd-translate-input ()
  "Prompt for text and translate with Youdao."
  (interactive)
  (let* ((word (read-string "Translate: " (thing-at-point 'word t)))
         (result (yd--query word)))
    (message "%s" result)))

(provide 'init-translate)
;;; init-translate.el ends here
