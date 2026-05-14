;; Mac平台下交换 Option 和 Command 键。
(when (featurep 'cocoa)
  (setq mac-option-modifier 'super)
  (setq mac-command-modifier 'meta))

;;; ### Unset key ###
;;; --- 卸载按键
(lazy-load-unset-keys                   ;全局按键的卸载
 '("C-z" "C-q" "s-T" "s-W" "s-z" "M-h" "C-x C-c" "C-\\" "s-c" "s-x" "s-v" "C-6" "M-." "M-,"))

;;; ### Color-Rg ###
;;; --- 搜索重构
(lazy-load-global-keys
 '(
   ("s-x g" . color-rg-search-symbol)
   ("s-x h" . color-rg-search-input)
   ("s-x j" . color-rg-search-symbol-in-project)
   ("s-x k" . color-rg-search-input-in-project)
   ("s-x ," . color-rg-search-symbol-in-current-file)
   ("s-x ." . color-rg-search-input-in-current-file)
   )
 "color-rg")

(lazy-load-global-keys
 '(
   ("M-2" . indent-buffer)               ;自动格式化当前Buffer
   ("s-g" . goto-percent)    ;跳转到当前Buffer的文本百分比, 单位为字符
   ("<f2>" . refresh-file)              ;自动刷新文件
   ("s-r" . find-file-smb)              ;访问sambao
   ("s-f" . find-file-root)             ;用root打开文件

   ("C-z l" . display-line-numbers-mode) ;行号模式切换
   ("M-s-n" . comment-part-move-down)    ;向下移动注释
   ("M-s-p" . comment-part-move-up)      ;向上移动注释
   ("C-s-n" . comment-dwim-next-line)    ;移动到上一行并注释
   ("C-s-p" . comment-dwim-prev-line)    ;移动到下一行并注释
   ("M-z" . upcase-char)      ;Upcase char handly with capitalize-word
   ("C-x u" . mark-line)      ;选中整行
   ("s-k" . kill-and-join-forward)      ;在缩进的行之间删除
   ("M-G" . goto-column)                ;到指定列
   ("C->" . remember-init)              ;记忆初始函数
   ("C-<" . remember-jump)              ;记忆跳转函数
   ("M-s-," . point-stack-pop)          ;buffer索引跳转
   ("M-s-." . point-stack-push)         ;buffer索引标记
   )
 "basic-toolkit")

(lazy-load-global-keys
 '(
   ("M-g" . goto-line-preview))
 "goto-line-preview")

;;; ### Delete block ###
;;; --- 快速删除光标左右的内容
(lazy-load-global-keys
 '(
   ("M-N" . delete-block-backward)
   ("M-M" . delete-block-forward))
 "delete-block")

;;; ### Watch other window ###
;;; --- 滚动其他窗口
(lazy-load-global-keys
 '(
   ("M-J" . watch-other-window-up)        ;向下滚动其他窗口
   ("M-K" . watch-other-window-down)      ;向上滚动其他窗口
   ("M-<" . watch-other-window-up-line)   ;向下滚动其他窗口一行
   ("M->" . watch-other-window-down-line) ;向上滚动其他窗口一行
   )
 "watch-other-window")

;;; ### Buffer Move ###
;;; --- 缓存移动
(lazy-load-set-keys
 '(
   ("C-z k" . beginning-of-buffer)      ;缓存开始
   ("C-z j" . end-of-buffer)            ;缓存结尾
   ("C-M-f" . forward-paragraph)        ;下一个段落
   ("C-M-b" . backward-paragraph)       ;上一个段落
   ("C-M-y" . backward-up-list)         ;向左跳出 LIST
   ("C-M-o" . up-list)                  ;向右跳出 LIST
   ("C-M-u" . backward-down-list)       ;向左跳进 LIST
   ("C-M-i" . down-list)                ;向右跳进 LIST
   ("C-M-a" . beginning-of-defun)       ;函数开头
   ("C-M-e" . end-of-defun)             ;函数末尾
   ))

(lazy-load-global-keys
 '(
   ("M-s" . symbol-overlay-put)         ;懒惰搜索
   )
 "init-symbol-overlay")

(lazy-load-global-keys
 '(
   ("s-N" . move-text-down)      ;把光标所在的整行文字(或标记)下移一行
   ("s-P" . move-text-up)        ;把光标所在的整行文字(或标记)上移一行
   )
 "move-text")

(lazy-load-global-keys
 '(
   ("C-o" . open-newline-above)         ;在上面一行新建一行
   ("C-l" . open-newline-below)         ;在下面一行新建一行
   )
 "open-newline")

;;; ### Buffer Edit ###
;;; --- 缓存编辑
(lazy-load-set-keys
 '(
   ("C-x C-x" . exchange-point-and-mark)   ;交换当前点和标记点
   ("M-o" . backward-delete-char-untabify) ;向前删除字符
   ("C-M-S-h" . mark-paragraph)            ;选中段落
   ("M-SPC" . just-one-space)              ;只有一个空格在光标处
   ))

;;; ### goto-last-change ###
;;; --- 跳到最后编辑的地方
(lazy-load-global-keys
 '(
   ("C-," . goto-last-change)           ;跳到最后编辑的地方
   )
 "goto-last-change")

;;; ### vundo ###
;;; --- 可视化撤销插件
(lazy-load-global-keys
 '(
   ("C-/" . undo)
   ("C-?" . vundo)
   )
 "init-vundo")

;;; ### Markmacro ###
;;; --- 标记对象的键盘宏操作
;; (lazy-load-global-keys
;;  '(
;;    ("s-h" . one-key-menu-mark-macro)     ;one-key菜单
;;    ("s-M" . markmacro-rect-set)          ;记录矩形编辑开始的位置
;;    ("s-D" . markmacro-rect-delete)       ;删除矩形区域
;;    ("s-F" . markmacro-rect-replace)      ;替换矩形区域的内容
;;    ("s-I" . markmacro-rect-insert)       ;在矩形区域前插入字符串
;;    ("s-C" . markmacro-rect-mark-columns) ;转换矩形列为标记对象
;;    ("s-S" . markmacro-rect-mark-symbols) ;转换矩形列对应的符号为标记对象
;;    ("s-<" . markmacro-apply-all)         ;应用键盘宏到所有标记对象
;;    ("s->" . markmacro-apply-all-except-first) ;应用键盘宏到所有标记对象, 除了第一个， 比如下划线转换的时候
;;    )
;;  "init-markmacro")

;;; ### Font ###
;;; --- 字体命令
(lazy-load-set-keys
 '(
   ("s--" . text-scale-decrease)        ;减小字体大小
   ("s-=" . text-scale-increase)        ;增加字体大小
   ))

(lazy-load-global-keys
 '(
   ("M-s-i" . ielm-toggle)              ;切换ielm
   ("<f5>" . emacs-session-save)        ;退出emacs
   ("C-4" . insert-changelog-date)      ;插入日志时间 (%Y/%m/%d)
   ("C-5" . insert-standard-date)
   ;; ("C-&" . switch-to-messages)         ;跳转到 *Messages* buffer
   )
 "lazycat-toolkit")

;; ### Blink Search ###
;;; --- 最快的搜索框架
(lazy-load-global-keys
 '(
   ("s-y" . blink-search)
   )
 "init-blink-search")

;; ### lsp-bridge ###
;;; --- 代码语法补全
(lazy-load-global-keys
 '(
   ("C-7" . lsp-bridge-find-def-return)
   ("C-8" . lsp-bridge-find-def)
   ("M-," . lsp-bridge-code-action)
   ("M-." . lsp-bridge-find-references)
   ("C-9" . lsp-bridge-popup-documentation)
   ("C-0" . lsp-bridge-rename)
   )
 "init-lsp-bridge")

;; ### popper ###
;;; --- 弹出窗口管理
(lazy-load-global-keys
 '(
   ("C-`" . popper-toggle-latest)
   ("M-`" . popper-cycle)
   ("C-M-`" . popper-toggle-type)
   )
 "init-popper")

(provide 'init-key)
