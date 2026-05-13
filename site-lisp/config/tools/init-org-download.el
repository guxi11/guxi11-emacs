;;; init-org-download.el --- org-download config for screenshot workflow

;;; Code:

(require 'org-download)

;; macOS 用 pngpaste 从剪贴板获取截图
(setq org-download-screenshot-method "pngpaste %s")

;; 图片保存到当前 org 文件同级的 images/ 目录
(setq org-download-image-dir "./images")

;; 不按 heading 创建子目录
(setq org-download-heading-lvl nil)

;; 用 directory 方式存储（而非 attach）
(setq org-download-method 'directory)

;; 文件名：时间戳，避免冲突
(setq org-download-timestamp "%Y%m%d-%H%M%S-")

;; 插入链接后自动显示图片
(setq org-download-display-inline-images t)

;; org-mode 下自动启用拖拽图片支持
(add-hook 'org-mode-hook #'org-download-enable)

(provide 'init-org-download)

;;; init-org-download.el ends here
