;;; init-org-rank.el --- Persistent manual sort for org-agenda

;;; Code:

(defvar org-rank-debug nil
  "Non-nil 时打印 org-rank 的内部状态到 *Messages*，用于排查排序/rank 异常。")

(defun org-rank--log (fmt &rest args)
  (when org-rank-debug
    (apply #'message (concat "[org-rank] " fmt) args)))

;;;; ── Rank algebra ──────────────────────────────────────────────────────────
;;
;; Ranks are variable-length strings over [a-z], compared lexicographically.
;;
;; midpoint(A, B) — always finds M with A < M < B by extending when adjacent:
;;
;;   Let i = first differing index (A may be exhausted there).
;;   ca = A[i]  (or virtual-min = 'a'-1 if A exhausted)
;;   cb = B[i]  (always exists since A < B)
;;   diff = cb - ca
;;
;;   diff > 1  →  prefix + chr(ca + diff/2)                   easy midpoint
;;
;;   diff = 1, A not exhausted  →  prefix + ca + A[i+1:] + 'm'
;;                                 (> A because A[i+1:] is proper prefix;
;;                                  < B because first diff char ca < cb)
;;
;;   diff = 1, A exhausted  →  B = prefix + "a" + B-rest
;;     B-rest non-empty  →  prefix + "a"   (proper prefix of B, > A = prefix)
;;     B-rest empty      →  signal `org-rank-too-dense' (B = A+"a", no room)
;;
;; The impossible-case (B = A+"a") requires hundreds of boundary insertions
;; in practice; call org-rank-rebalance to recover.

(define-error 'org-rank-too-dense
  "Ranks too dense to insert; call M-x org-rank-rebalance")

(defconst org-rank-prop         "RANK")
(defconst org-rank-min-char     ?a)
(defconst org-rank-max-char     ?z)
(defconst org-rank-mid-char     ?m)
(defconst org-rank--virtual-min (1- ?a))   ; = 96, below alphabet

;; Exclusive sentinels — never assigned to actual items
(defconst org-rank--floor "a")
(defconst org-rank--ceil  "z")

(defun org-rank--first-diff (a b)
  "Index of first position where A and B differ (capped at shorter length)."
  (let ((i 0) (la (length a)) (lb (length b)))
    (while (and (< i la) (< i lb) (= (aref a i) (aref b i)))
      (setq i (1+ i)))
    i))

(defun org-rank--midpoint (a b)
  "Return string M with A < M < B (variable-length; always works unless B = A+\"a\").
Signals `org-rank-too-dense' only in that degenerate case."
  ;; 软失败：上层 auto-init 会捕获并提示 rebalance；硬 error 会让整个
  ;; org-agenda-finalize-hook 崩掉，污染所有 agenda 视图。
  (unless (string< a b)
    (signal 'org-rank-too-dense (list a b)))
  (let* ((la  (length a))
         (lb  (length b))
         (i   (org-rank--first-diff a b))
         (pre (substring a 0 i))
         ;; ca: actual char, or virtual-min if A is exhausted at i
         (ca  (if (< i la) (aref a i) org-rank--virtual-min))
         ;; cb: always valid — after prefix, B must still have a char (A < B)
         (cb  (aref b i))
         (diff (- cb ca)))
    (cond
     ;; ── Gap ≥ 2: pick a char in the middle ───────────────────────────────
     ((> diff 1)
      ;; When ca is virtual-min, mid may equal min-char ('a') — still valid.
      (concat pre (string (max (+ ca (/ diff 2)) org-rank-min-char))))

     ;; ── Adjacent (diff = 1) ───────────────────────────────────────────────
     ((= diff 1)
      (if (/= ca org-rank--virtual-min)
          ;; A has a real char: extend with A's suffix + mid-char.
          ;;   > A  : A[i+1:] is proper prefix of (A[i+1:] + mid-char)
          ;;   < B  : starts with prefix+ca, B starts with prefix+cb=prefix+(ca+1)
          (concat pre (string ca)
                  (substring a (min (1+ i) la))
                  (string org-rank-mid-char))
        ;; A is exhausted: B = prefix + "a" + B-rest
        (let ((b-rest (substring b (1+ i))))
          (if (string-empty-p b-rest)
              ;; B = A + "a" — genuinely no room in our alphabet
              (signal 'org-rank-too-dense (list a b))
            ;; prefix < prefix+"a" < prefix+"a"+B-rest = B  ✓
            (concat pre (string org-rank-min-char))))))

     (t
      ;; diff = 0 is impossible here:
      ;;   - Equal non-exhausted chars would have been consumed in first-diff.
      ;;   - virtual-min and 'a'-1 can't both appear (cb >= 'a' always).
      (error "org-rank--midpoint: impossible diff=0 a=%S b=%S" a b)))))

(defun org-rank--split (lo hi n)
  "Return list of N rank strings, binary-split evenly between LO and HI.
May signal `org-rank-too-dense'."
  (cond
   ((= n 0) '())
   ((= n 1) (list (org-rank--midpoint lo hi)))
   (t
    (let* ((mid     (org-rank--midpoint lo hi))
           (left-n  (/ n 2))
           (right-n (- n left-n 1)))
      (append (org-rank--split lo mid left-n)
              (list mid)
              (org-rank--split mid hi right-n))))))

;;;; ── Org property helpers ─────────────────────────────────────────────────

(defun org-rank--get ()
  "Return rank for entry at point, or nil if unset/invalid.
非 [a-z]+ 的值（空串、手写大写、复制粘贴脏数据）一律当作未 rank，
让 auto-init 有机会把它修正掉。"
  (let ((r (org-entry-get nil org-rank-prop)))
    (and (stringp r) (string-match-p "\\`[a-z]+\\'" r) r)))

(defun org-rank--set (rank)
  "Set RANK for entry at point. nil / 非法值一律拒绝，避免 org-entry-put
把属性删掉造成级联故障。"
  (when (and (stringp rank) (string-match-p "\\`[a-z]+\\'" rank))
    (org-entry-put nil org-rank-prop rank)))

(defun org-rank--entry-rank (entry)
  "Read RANK from agenda ENTRY string via its org-marker."
  (when-let ((m (get-text-property 0 'org-marker entry)))
    (org-with-point-at m (org-rank--get))))

;;;; ── Comparator ────────────────────────────────────────────────────────────

(defun org-rank-cmp (a b)
  "Comparator for `org-agenda-cmp-user-defined'.
约定：-1 = A 在前，+1 = B 在前，nil = 相等（交给次级键）。

排序规则（两段）：
  1. 带 time-of-day 的项（timeline）置顶，按时间升序；
  2. 其余项按 RANK 字典序；
  3. 没 rank 的项最后，保持相对顺序。"
  (let* ((ta (get-text-property 0 'time-of-day a))
         (tb (get-text-property 0 'time-of-day b))
         (ra (org-rank--entry-rank a))
         (rb (org-rank--entry-rank b))
         (r (cond
             ;; 两者都有 time → 时间升序
             ((and ta tb) (cond ((< ta tb) -1) ((> ta tb) +1) (t nil)))
             ;; 只有 a 有 time → a 前（timeline 置顶）
             (ta -1)
             (tb +1)
             ;; 都没 time → 按 rank
             ((and ra rb) (cond ((string< ra rb) -1)
                                ((string< rb ra) +1)
                                (t nil)))
             (ra  -1)
             (rb  +1)
             (t   nil))))
    (org-rank--log "cmp ta=%S tb=%S ra=%S rb=%S -> %S" ta tb ra rb r)
    r))

;;;; ── Agenda item collection ────────────────────────────────────────────────

(defun org-rank--agenda-items ()
  "Ordered list of (line-pos . marker) for rankable items in agenda buffer.
Timeline 项（有 time-of-day 属性）被排除：它们按时间置顶，不参与 rank 体系。"
  (save-excursion
    (goto-char (point-min))
    (let (items)
      (while (< (point) (point-max))
        (let ((m (get-text-property (point) 'org-marker))
              (tod (get-text-property (point) 'time-of-day)))
          (when (and m (not tod))
            (push (cons (line-beginning-position) m) items)))
        (forward-line 1))
      (nreverse items))))

;;;; ── Auto-initialization ───────────────────────────────────────────────────

(defun org-rank--auto-init ()
  "Assign RANKs to unranked items in the current agenda view.
Works cross-file via org-marker.  Hooked onto `org-agenda-finalize-hook'.

First run (nothing ranked): evenly distribute all items via binary splitting.
Mixed run (some ranked):    for each contiguous block of unranked items,
                            interpolate between nearest ranked neighbors."
  (let* ((items (org-rank--agenda-items))
         (n     (length items)))
    (org-rank--log "auto-init: %d items in buffer %S" n (buffer-name))
    (when (> n 0)
      (let* ((rank-of    (lambda (x) (org-with-point-at (cdr x) (org-rank--get))))
             (any-ranked (cl-some rank-of items)))
        (if (not any-ranked)
            ;; ── First run: distribute everything ─────────────────────────
            (progn
              (org-rank--log "auto-init: first-run, distributing %d items" n)
              (cl-loop for item in items
                       for r    in (org-rank--split org-rank--floor org-rank--ceil n)
                       do (org-with-point-at (cdr item) (org-rank--set r))))
          ;; ── Mixed: walk and handle each contiguous unranked run ───────
          (let ((i 0))
            (while (< i n)
              (if (funcall rank-of (nth i items))
                  (cl-incf i)
                (let* ((run-start i)
                       (run-end   (cl-loop for j from i below n
                                           while (not (funcall rank-of (nth j items)))
                                           finally return j))
                       (run-len   (- run-end run-start))
                       (prev-rank (or (cl-loop for j downfrom (1- run-start) to 0
                                               for r = (funcall rank-of (nth j items))
                                               when r return r)
                                      org-rank--floor))
                       (next-rank (or (and (< run-end n)
                                           (funcall rank-of (nth run-end items)))
                                      org-rank--ceil)))
                  (cond
                   ;; prev >= next：items 已过滤 timeline，视觉序应严格按
                   ;; rank 字典序。触发此分支意味着 RANK 属性被外部脏写
                   ;; （复制粘贴重复、手工乱编），跳过并提示 rebalance。
                   ((not (string< prev-rank next-rank))
                    (message "org-rank: dirty ranks around %S/%S — M-x org-rank-rebalance"
                             prev-rank next-rank))
                   (t
                    (org-rank--log "auto-init: fill run [%d,%d) between %S..%S"
                                   run-start run-end prev-rank next-rank)
                    (condition-case err
                        (cl-loop for item in (cl-subseq items run-start run-end)
                                  for r    in (org-rank--split prev-rank next-rank run-len)
                                  do (org-with-point-at (cdr item) (org-rank--set r)))
                      (org-rank-too-dense
                       (message "org-rank: %s — call M-x org-rank-rebalance"
                                (cadr err))))))
                  (setq i run-end))))))))))

;;;; ── Rebalance ─────────────────────────────────────────────────────────────

(defun org-rank-rebalance ()
  "Reassign RANKs to all items in current agenda view, evenly spaced.
Preserves the current visual order.  Use when ranks become too dense."
  (interactive)
  (let* ((items (org-rank--agenda-items))
         (n     (length items)))
    (cl-loop for item in items
             for r    in (org-rank--split org-rank--floor org-rank--ceil n)
             do (org-with-point-at (cdr item) (org-rank--set r)))
    (org-agenda-redo t)
    (message "org-rank: rebalanced %d items" n)))

;;;; ── Move up / down ────────────────────────────────────────────────────────

(defun org-rank--marker-at-p (marker buf pos)
  "True if text-property org-marker at point matches BUF and POS."
  (when-let ((m (get-text-property (point) 'org-marker)))
    (and (eq  (marker-buffer   m) buf)
         (eql (marker-position m) pos))))

(defun org-rank-move (delta)
  "Swap RANK of current agenda item with neighbor DELTA positions away."
  (org-rank--log "move delta=%d" delta)
  (let* ((cur-marker (org-get-at-bol 'org-marker)))
    (unless cur-marker (user-error "No org item at point"))
    ;; Ensure every visible item has a rank before swapping.
    ;; Without this, swapping a nil rank calls org-entry-put with nil,
    ;; which DELETES the neighbor's rank instead of setting it.
    (org-rank--auto-init)
    (let* ((items   (org-rank--agenda-items))
           (idx     (cl-position cur-marker items :key #'cdr :test #'equal)))
      (unless idx (user-error "No org item at point"))
      (let ((nei-idx (+ idx delta)))
        (unless (and (>= nei-idx 0) (< nei-idx (length items)))
          (user-error "Already at boundary"))
        (let* ((nei-marker (cdr (nth nei-idx items)))
               (cur-buf    (marker-buffer   cur-marker))
               (cur-pos    (marker-position cur-marker))
               (r1 (org-with-point-at cur-marker (org-rank--get)))
               (r2 (org-with-point-at nei-marker (org-rank--get))))
          (org-rank--log "move: idx=%d nei-idx=%d r1=%S r2=%S" idx nei-idx r1 r2)
          ;; 兜底：auto-init 对「视觉顺序 != rank 顺序」的 run 是跳过的
          ;; （见 org-rank--auto-init 里的 prev >= next 分支），所以这里
          ;; 仍可能遇到 r1/r2 为 nil 或两者相等的情况。直接 rebalance
          ;; 重算，再读一次。
          (when (or (null r1) (null r2) (string= r1 r2))
            (org-rank-rebalance)
            (setq items (org-rank--agenda-items)
                  idx   (cl-position cur-marker items :key #'cdr :test #'equal))
            (unless idx (user-error "No org item at point"))
            (setq nei-idx (+ idx delta))
            (unless (and (>= nei-idx 0) (< nei-idx (length items)))
              (user-error "Already at boundary"))
            (setq nei-marker (cdr (nth nei-idx items))
                  r1 (org-with-point-at cur-marker (org-rank--get))
                  r2 (org-with-point-at nei-marker (org-rank--get))))
          (let ((inhibit-redisplay t))
            (org-with-point-at cur-marker (org-rank--set r2))
            (org-with-point-at nei-marker (org-rank--set r1))
            (org-agenda-redo t))
          (goto-char (point-min))
          (catch 'found
            (while (< (point) (point-max))
              (if (org-rank--marker-at-p cur-marker cur-buf cur-pos)
                  (throw 'found t)
                (forward-line 1))))
          (recenter))))))

(defun org-rank-move-up   () (interactive) (org-rank-move -1))
(defun org-rank-move-down () (interactive) (org-rank-move  1))

;;;; ── Wire up ────────────────────────────────────────────────────────────────

(setq org-agenda-cmp-user-defined #'org-rank-cmp)
(add-hook 'org-agenda-finalize-hook #'org-rank--auto-init)

;; 强制 user-defined-up 参与排序。
;;
;; 历史教训（为什么前两版都失效）：
;;   v1：改全局 `org-agenda-sorting-strategy'。custom command 里的 :option
;;       override、用户后续 setq 都能覆盖它。
;;   v2：:around advice 包 `org-agenda-finalize-entries', let-bind
;;       `org-agenda-sorting-strategy'。——但 `org-entries-lessp' 用的是
;;       `org-agenda-sorting-strategy-selected'（flat list），这个变量早在
;;       每个 agenda command 里由 `org-set-sorting-strategy' 从 alist 里
;;       挑出来 setq 了。advice 改的不是 sort 那一步读的变量，所以
;;       `user-defined-up' 从来没进 -selected，`org-rank-cmp' 一次都没跑。
;;
;; 现方案：:after advice 钉在 `org-set-sorting-strategy' 上。这个函数就是
;; 专门写 `-selected' 的唯一入口，advice 在它 setq 完之后紧接着把
;; `user-defined-up' 塞到首位。任何后续的 sort 一定读到我们改过的值。
(defun org-rank--ensure-selected (&rest _)
  "把 `user-defined-up' 顶到 `org-agenda-sorting-strategy-selected' 首位。"
  (setq org-agenda-sorting-strategy-selected
        (cons 'user-defined-up
              (remq 'user-defined-up
                    (remq 'user-defined-down
                          org-agenda-sorting-strategy-selected))))
  (org-rank--log "sorting-strategy-selected = %S"
                 org-agenda-sorting-strategy-selected))

(with-eval-after-load 'org-agenda
  (advice-add 'org-set-sorting-strategy :after #'org-rank--ensure-selected))

;; Rebind J/K (and M-j/M-k) in org-agenda. 三层保险：
;;   1. `with-eval-after-load 'org-agenda'` 直接 `define-key` 到
;;      `org-agenda-mode-map'。这是最底层的 map，evil 任何 state 回落
;;      都能命中。evil-org-agenda 的 motion-state aux map 优先级高于
;;      base map，但当 aux map 里没绑（或被清掉）时就走这里。
;;   2. `with-eval-after-load 'evil-org-agenda'` 在 motion/normal state
;;      aux map 里顶掉 evil-org-agenda 默认的 priority(J/K) 和 drag(M-j/M-k)。
;;      (没改就会被 drag 抢走：按了能动但 rebuild 复位。)
;;   3. `org-agenda-mode-hook` + buffer-local 兜底，防止后续包覆盖 aux map。
(with-eval-after-load 'org-agenda
  (define-key org-agenda-mode-map (kbd "J")   #'org-rank-move-down)
  (define-key org-agenda-mode-map (kbd "K")   #'org-rank-move-up)
  (define-key org-agenda-mode-map (kbd "M-j") #'org-rank-move-down)
  (define-key org-agenda-mode-map (kbd "M-k") #'org-rank-move-up))

(with-eval-after-load 'evil-org-agenda
  (evil-define-key '(motion normal) org-agenda-mode-map
    (kbd "J")   #'org-rank-move-down
    (kbd "K")   #'org-rank-move-up
    (kbd "M-j") #'org-rank-move-down
    (kbd "M-k") #'org-rank-move-up))

(add-hook 'org-agenda-mode-hook
          (lambda ()
            (dolist (state '(motion normal))
              (evil-local-set-key state (kbd "J")   #'org-rank-move-down)
              (evil-local-set-key state (kbd "K")   #'org-rank-move-up)
              (evil-local-set-key state (kbd "M-j") #'org-rank-move-down)
              (evil-local-set-key state (kbd "M-k") #'org-rank-move-up))))

(provide 'init-org-rank)
;;; init-org-rank.el ends here
