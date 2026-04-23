;;; init-org-rank.el --- Persistent manual sort for org-agenda

;;; Code:

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
Ranked items sort before unranked; unranked items preserve relative order."
  (let ((ra (org-rank--entry-rank a))
        (rb (org-rank--entry-rank b)))
    (cond
     ((and ra rb) (cond ((string< ra rb) -1)
                        ((string< rb ra) +1)
                        (t nil)))
     (ra  -1)    ; a ranked, b not → a first
     (rb  +1)
     (t   nil))))

;;;; ── Agenda item collection ────────────────────────────────────────────────

(defun org-rank--agenda-items ()
  "Ordered list of (line-pos . marker) for all org items in the agenda buffer."
  (save-excursion
    (goto-char (point-min))
    (let (items)
      (while (< (point) (point-max))
        (when-let ((m (get-text-property (point) 'org-marker)))
          (push (cons (line-beginning-position) m) items))
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
    (when (> n 0)
      (let* ((rank-of    (lambda (x) (org-with-point-at (cdr x) (org-rank--get))))
             (any-ranked (cl-some rank-of items)))
        (if (not any-ranked)
            ;; ── First run: distribute everything ─────────────────────────
            (cl-loop for item in items
                     for r    in (org-rank--split org-rank--floor org-rank--ceil n)
                     do (org-with-point-at (cdr item) (org-rank--set r)))
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
                   ;; prev >= next: 视觉顺序和 rank 顺序不一致（比如 agenda
                   ;; 视图按 time-of-day 排序、或手工/复制造成重复 rank），
                   ;; 此时任何 midpoint 都会违反断言。跳过本 run，等用户
                   ;; M-x org-rank-rebalance 或切到 rank 排序的视图再处理。
                   ((not (string< prev-rank next-rank))
                    (message "org-rank: skip run (prev=%S >= next=%S); \
visual order disagrees with rank — call M-x org-rank-rebalance if needed"
                             prev-rank next-rank))
                   (t
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

;; Prepend user-defined-up to every agenda sorting strategy so rank is respected.
;; 只对非 agenda 类型注入 user-defined-up，保留 agenda 视图的 time-of-day 优先排序
(with-eval-after-load 'org-agenda
  (dolist (entry org-agenda-sorting-strategy)
    (unless (or (memq (car entry) '(agenda))
                (memq 'user-defined-up (cdr entry)))
      (setcdr entry (cons 'user-defined-up (cdr entry))))))

;; Use buffer-local evil bindings (highest priority, beats evil-org-agenda globals).
;; evil-org-agenda-set-keys binds M-j/k to the non-persistent built-in drag commands;
;; evil-local-set-key in a mode hook wins over those global motion-state bindings.
(add-hook 'org-agenda-mode-hook
          (lambda ()
            (evil-local-set-key 'motion (kbd "M-j") #'org-rank-move-down)
            (evil-local-set-key 'motion (kbd "M-k") #'org-rank-move-up)))

(provide 'init-org-rank)
;;; init-org-rank.el ends here
