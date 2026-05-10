;;; init-css-mode-u.el --- Color preview for CSS-family modes -*- lexical-binding: t -*-
;;; Commentary:
;; `colorful-mode' supersedes `rainbow-mode' and natively previews
;; modern CSS color functions (oklch / oklab / lch / lab / color-mix).
;;; Code:

(use-package colorful-mode
  :ensure t
  :hook ((css-mode css-ts-mode scss-mode less-css-mode web-mode) . colorful-mode)
  :custom
  (colorful-use-prefix nil)
  (colorful-allow-mouse-clicks t))

(provide 'init-css-mode-u)
;;; init-css-mode-u.el ends here
