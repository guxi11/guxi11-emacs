;;; init-org-download.el --- org-download config for screenshot workflow

;;; Code:

(require 'org-download)

;; macOS 用 pngpaste 从剪贴板获取截图
(setq org-download-screenshot-method "pngpaste %s")

;; 图片保存到当前 org 文件同级的 images/ 目录
(setq-default org-download-image-dir "./images")

;; 不按 heading 创建子目录
(setq org-download-heading-lvl nil)

;; 用 directory 方式存储（而非 attach）
(setq org-download-method 'directory)

;; 文件名：用 org 文件 title + 时间戳，保持小写
(defun my/org-download-file-formater (filename)
  "Generate download filename from org #+title and timestamp."
  (let* ((title (or (org-get-title) (file-name-base (buffer-file-name)) "untitled"))
         ;; 小写，空格和特殊字符替换为连字符
         (slug (downcase (replace-regexp-in-string "[^a-zA-Z0-9一-鿿]+" "-" title)))
         (slug (replace-regexp-in-string "^-\\|-$" "" slug))
         (ts (format-time-string "%Y%m%d-%H%M%S"))
         (ext (file-name-extension filename)))
    (concat slug "-" ts "." ext)))

(setq org-download-file-format-function #'my/org-download-file-formater)

;; 插入链接后自动显示图片
(setq org-download-display-inline-images t)

;; Retina 屏截图是 2x 像素，用 :scale 0.5 显示为实际尺寸的一半
(setq org-image-actual-width t)

(defun my/org-retina-scale-image (img)
  "Scale inline image to half size for Retina display."
  (when img
    (plist-put (cdr img) :scale 0.5))
  img)

(advice-add 'org--create-inline-image :filter-return #'my/org-retina-scale-image)

;; org-mode 下自动启用拖拽图片支持
(add-hook 'org-mode-hook #'org-download-enable)

(provide 'init-org-download)

;;; init-org-download.el ends here
