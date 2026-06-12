;;; gptel-usage-tracker.el --- Token usage tracking for gptel
;;
;; Drop this into your main-config.org as a src block, or require it directly.
;; Depends on: gptel, built-in sqlite (Emacs 29+)
;;
;; Storage: ~/.emacs.d/gptel-usage.db (SQLite)
;; Log archive: *gptel-log-YYYY-MM* buffers
;;
;; Entry points:
;;   M-x my/gptel-usage-report       — show usage summary buffer
;;   M-x my/gptel-archive-log        — archive + clear current log (run monthly)
;;   my/gptel-log-usage is hooked automatically via gptel-post-response-hook

;;; ─── Pricing table ────────────────────────────────────────────────────────────
;; (input-price . output-price) per 1,000,000 tokens in USD

(defvar my/gptel-pricing
  '(("claude-sonnet-4-6"         . (3.00  . 15.00))
    ("claude-opus-4-6"           . (15.00 . 75.00))
    ("claude-haiku-4-5-20251001" . (0.25  .  1.25)))
  "Pricing per million tokens for each model. (input . output) in USD.")

;;; ─── DB setup ─────────────────────────────────────────────────────────────────

(defvar my/gptel-db-path
  (expand-file-name "gptel-usage.db" user-emacs-directory))

(defvar my/gptel-db nil
  "Active sqlite connection to the usage DB.")

(defun my/gptel-db ()
  "Return active DB connection, opening it if needed."
  (unless my/gptel-db
    (setq my/gptel-db (sqlite-open my/gptel-db-path))
    (sqlite-execute my/gptel-db
      "CREATE TABLE IF NOT EXISTS usage (
         id INTEGER PRIMARY KEY AUTOINCREMENT,
         timestamp TEXT NOT NULL,
         date TEXT NOT NULL,
         model TEXT NOT NULL,
         input_tokens INTEGER NOT NULL,
         output_tokens INTEGER NOT NULL,
         estimated_cost REAL NOT NULL)"))
  my/gptel-db)

;;; ─── Parser ───────────────────────────────────────────────────────────────────

(defun my/gptel-parse-last-request ()
  "Parse the most recent request/response from *gptel-log*.
Returns a plist (:model :input :output :timestamp) or nil if not found."
  (with-current-buffer (get-buffer-create "*gptel-log*")
    (save-excursion
      (goto-char (point-max))
      (let ((model nil)
            (input nil)
            (output nil)
            (timestamp nil))
        ;; Find final confirmed token counts from message_delta
        (when (re-search-backward
               "\"input_tokens\":\\s-*\\([0-9]+\\).*\"output_tokens\":\\s-*\\([0-9]+\\)"
               nil t)
          (setq input  (string-to-number (match-string 1))
                output (string-to-number (match-string 2)))
          (when (re-search-backward "\"model\":\\s-*\"\\([^\"]+\\)\"" nil t)
            (setq model (match-string 1)))
          (when (re-search-backward "\"timestamp\":\\s-*\"\\([^\"]+\\)\"" nil t)
            (setq timestamp (match-string 1))))
        (when (and model input output)
          (list :model     model
                :input     input
                :output    output
                :timestamp (or timestamp
                               (format-time-string "%Y-%m-%d %H:%M:%S"))))))))

;;; ─── Cost calculator ──────────────────────────────────────────────────────────

(defun my/gptel-estimate-cost (model input-tokens output-tokens)
  "Estimate USD cost for MODEL with INPUT-TOKENS and OUTPUT-TOKENS."
  (let* ((pricing (alist-get model my/gptel-pricing nil nil #'string=))
         (in-price  (or (car pricing) 3.00))
         (out-price (or (cdr pricing) 15.00)))
    (+ (/ (* input-tokens  in-price)  1000000.0)
       (/ (* output-tokens out-price) 1000000.0))))

;;; ─── Logger ───────────────────────────────────────────────────────────────────

(defun my/gptel-log-usage (beg end)
  "Parse last gptel response and store token usage in DB.
BEG and END are the response region bounds passed by gptel-post-response-hook."
  (when-let ((data (my/gptel-parse-last-request)))
    (let* ((model     (plist-get data :model))
           (input     (plist-get data :input))
           (output    (plist-get data :output))
           (timestamp (plist-get data :timestamp))
           (date      (substring timestamp 0 10))
           (cost      (my/gptel-estimate-cost model input output)))
      (sqlite-execute (my/gptel-db)
        "INSERT INTO usage (timestamp, date, model, input_tokens, output_tokens, estimated_cost)
         VALUES (?, ?, ?, ?, ?, ?)"
        (list timestamp date model input output cost)))))

(add-hook 'gptel-post-response-hook #'my/gptel-log-usage)

;;; ─── Report ───────────────────────────────────────────────────────────────────

(defun my/gptel-usage-report ()
  "Display a token usage and cost summary buffer."
  (interactive)
  (let* ((db (my/gptel-db))
         (daily (sqlite-select db
                  "SELECT date, SUM(input_tokens), SUM(output_tokens), SUM(estimated_cost)
                   FROM usage
                   WHERE date > date('now', '-30 days')
                   GROUP BY date ORDER BY date DESC"))
         (by-model (sqlite-select db
                     "SELECT model, SUM(input_tokens), SUM(output_tokens),
                             SUM(estimated_cost), COUNT(id)
                      FROM usage
                      GROUP BY model ORDER BY SUM(estimated_cost) DESC"))
         (monthly (sqlite-select db
                    "SELECT SUM(input_tokens), SUM(output_tokens), SUM(estimated_cost)
                     FROM usage WHERE date > date('now', '-30 days')"))
         (buf (get-buffer-create "*gptel-usage*")))
    (with-current-buffer buf
      (read-only-mode -1)
      (erase-buffer)
      (org-mode)
      (insert "#+TITLE: gptel Token Usage Report\n")
      (insert (format "#+DATE: %s\n\n" (format-time-string "%Y-%m-%d")))

      (insert "* Last 30 Days\n\n")
      (when monthly
        (let ((row (car monthly)))
          (insert (format "| Input tokens   | %12d |\n" (or (nth 0 row) 0)))
          (insert (format "| Output tokens  | %12d |\n" (or (nth 1 row) 0)))
          (insert (format "| Estimated cost | $%11.4f |\n\n" (or (nth 2 row) 0.0)))))

      (insert "* By Model (All Time)\n\n")
      (insert "| Model | Input | Output | Cost | Requests |\n")
      (insert "|---|---|---|---|---|\n")
      (dolist (row by-model)
        (insert (format "| %s | %d | %d | $%.4f | %d |\n"
                        (nth 0 row)
                        (or (nth 1 row) 0)
                        (or (nth 2 row) 0)
                        (or (nth 3 row) 0.0)
                        (or (nth 4 row) 0))))
      (insert "\n")

      (insert "* Daily Breakdown (Last 30 Days)\n\n")
      (insert "| Date | Input | Output | Cost |\n")
      (insert "|---|---|---|---|\n")
      (dolist (row daily)
        (insert (format "| %s | %d | %d | $%.4f |\n"
                        (nth 0 row)
                        (or (nth 1 row) 0)
                        (or (nth 2 row) 0)
                        (or (nth 3 row) 0.0))))
      (org-table-iterate-buffer-tables)
      (read-only-mode 1)
      (goto-char (point-min)))
    (switch-to-buffer buf)))

;;; ─── Monthly archive ──────────────────────────────────────────────────────────

(defun my/gptel-archive-log ()
  "Archive *gptel-log* to a dated buffer and clear it.
Run this at the start of each month."
  (interactive)
  (when (get-buffer "*gptel-log*")
    (let ((archive-name (format "*gptel-log-%s*"
                                (format-time-string "%Y-%m"))))
      (with-current-buffer "*gptel-log*"
        (copy-to-buffer (get-buffer-create archive-name)
                        (point-min) (point-max))
        (erase-buffer))
      (message "gptel log archived to %s" archive-name))))

;;; ─── Optional: echo cost after each response ─────────────────────────────────

(defun my/gptel-echo-cost (beg end)
  "Echo estimated cost of last request in minibuffer."
  (when-let ((data (my/gptel-parse-last-request)))
    (let* ((model  (plist-get data :model))
           (input  (plist-get data :input))
           (output (plist-get data :output))
           (cost   (my/gptel-estimate-cost model input output)))
      (message "gptel: %d in / %d out tokens — est. $%.5f" input output cost))))

;; Uncomment to enable per-response cost echo:
;; (add-hook 'gptel-post-response-hook #'my/gptel-echo-cost)

(provide 'gptel-usage-tracker)
;;; gptel-usage-tracker.el ends here
