;;; clock-dock.el --- Docked clock, clocked task and timer strip -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Tyler

;; Author: Tyler <https://github.com/Timmymayes>
;; Version: 0.3.5
;; Package-Requires: ((emacs "29.1") (org "9.5"))
;; Keywords: calendar, convenience, outlines
;; URL: https://github.com/Timmymayes/clock-dock

;; This file is not part of GNU Emacs.

;; Released under the MIT License.  See the LICENSE file in the
;; repository for the full text.

;;; Commentary:

;; A thin dock at the top of the editing area.  A large clock sits on the
;; left; on the right are two stacked lines: the task you are clocked into
;; with Org (time spent, and its Effort when set) and the running
;; `org-timer' countdown with an optional label.
;;
;; The Clocked In line turns yellow when you pass a fraction of the task's
;; Effort and red once you are over it.
;;
;; The dock attaches to the main editing area, not the whole frame, so
;; side windows such as Treemacs keep the full height of their column.
;; Its height is sized in pixels from the clock and info line heights and
;; is refit whenever the window layout changes.
;;
;; Usage:
;;
;;   M-x clock-dock-toggle
;;
;; The package binds no keys.  Bind your own, for example:
;;
;;   (global-set-key (kbd "C-c C") #'clock-dock-toggle)

;;; Code:

(require 'org)
(require 'org-clock)
(require 'org-timer)
(require 'org-duration)

(defgroup clock-dock nil
  "A docked clock, clocked task and timer strip."
  :group 'org-clock
  :prefix "clock-dock-")

(defcustom clock-dock-clock-height 3.0
  "Face height of the big clock digits."
  :type 'number)

(defcustom clock-dock-info-height 1.3
  "Face height of the two info lines."
  :type 'number)

(defcustom clock-dock-label-gap 2
  "Gap, in characters, between the labels and their values."
  :type 'integer)

(defcustom clock-dock-strip-padding 6
  "Extra pixels added below the dock's text."
  :type 'integer)

(defcustom clock-dock-clock-padding 20
  "Extra pixels added to the clock window's width."
  :type 'integer)

(defcustom clock-dock-time-format "%H:%M:%S"
  "Format string for the big clock, see `format-time-string'."
  :type 'string)

(defcustom clock-dock-separator t
  "Non-nil means draw a thin colored line under the dock.
Set this to nil if the line looks too thick with your theme.  The
dock reads this when it opens, so toggle it off and on to apply."
  :type 'boolean)

(defcustom clock-dock-separator-height 10
  "Absolute face height of the separator row, in 1/10 point.
The default, 10, is one point.  This is an absolute height on purpose:
a relative height such as 0.1 is not resolved in every setup and can
leave the row at full text height."
  :type 'integer)

(defcustom clock-dock-hide-scroll-bars t
  "Non-nil means hide the scroll bars in the dock windows."
  :type 'boolean)

(defcustom clock-dock-line-color "#88C0D0"
  "Color of the thin separator line under the dock."
  :type 'string)

(defcustom clock-dock-effort-warn 0.8
  "Fraction of the Effort at which the Clocked In line turns yellow."
  :type 'number)

(defcustom clock-dock-warn-color "#EBCB8B"
  "Color of the Clocked In line when near the Effort."
  :type 'string)

(defcustom clock-dock-over-color "#BF616A"
  "Color of the Clocked In line when over the Effort."
  :type 'string)

(defvar clock-dock-timer-label nil
  "Label for the running `org-timer' countdown, or nil.
Set it with `clock-dock-set-timer'.")

;;; Internal state

(defvar clock-dock--timer nil
  "Timer that redraws the dock once a second.")

(defvar clock-dock--busy nil
  "Non-nil while the dock is being opened, to block re-entry.")

(defvar clock-dock--fitting nil
  "Non-nil while the dock is resizing itself, to block recursion.")

(defconst clock-dock--clock-buf "*clock-dock-clock*")
(defconst clock-dock--info-buf "*clock-dock-info*")

;;; Org data helpers

(defun clock-dock--hhmm (minutes)
  "Format MINUTES as HH:MM."
  (format "%02d:%02d" (/ minutes 60) (% minutes 60)))

(defun clock-dock--effort ()
  "Effort string of the clocked task, or nil when none is set."
  (when (and (org-clocking-p) (marker-buffer org-clock-marker))
    (let ((e (org-with-point-at org-clock-marker
               (org-entry-get nil "Effort"))))
      (and e (not (string-empty-p e)) e))))

(defun clock-dock--effort-minutes ()
  "Effort of the clocked task in whole minutes, or nil."
  (let ((e (clock-dock--effort)))
    (and e (ignore-errors (round (org-duration-to-minutes e))))))

(defun clock-dock--task-string ()
  "Text for the Clocked In line."
  (if (org-clocking-p)
      (let ((spent (org-clock-get-clocked-time))
            (effort (clock-dock--effort-minutes))
            (title (substring-no-properties org-clock-heading)))
        (if (and effort (> effort 0))
            (format "%s (%s / %s)" title
                    (clock-dock--hhmm spent)
                    (clock-dock--hhmm effort))
          (format "%s (%s)" title (clock-dock--hhmm spent))))
    "Not clocked in"))

(defun clock-dock--task-face ()
  "Face for the Clocked In line: normal, warning, or over the Effort."
  (let ((effort (clock-dock--effort-minutes))
        (spent (and (org-clocking-p) (org-clock-get-clocked-time)))
        (h clock-dock-info-height))
    (cond ((and effort spent (> effort 0) (>= spent effort))
           `(:height ,h :foreground ,clock-dock-over-color))
          ((and effort spent (> effort 0)
                (>= spent (* effort clock-dock-effort-warn)))
           `(:height ,h :foreground ,clock-dock-warn-color))
          (t `(:height ,h)))))

(defun clock-dock--timer-string ()
  "Text for the Timer line."
  (if (and (boundp 'org-timer-countdown-timer) org-timer-countdown-timer)
      (concat (or clock-dock-timer-label "Running")
              " " (org-timer-value-string))
    "No timer running"))

;;; Layout helpers

(defun clock-dock--value-column ()
  "Pixel column where values start: the widest label plus the gap."
  (let ((face `(:height ,clock-dock-info-height)))
    (+ (apply #'max
              (mapcar (lambda (s) (string-pixel-width (propertize s 'face face)))
                      '("Clocked In:" "Timer:")))
       (* clock-dock-label-gap (frame-char-width)))))

(defun clock-dock--line (label value face)
  "One info line: LABEL, then VALUE starting at the shared pixel column."
  (concat (propertize label 'face face)
          (propertize " " 'display
                      `(space :align-to (,(clock-dock--value-column))))
          (propertize value 'face face)))

(defun clock-dock--content-pixels ()
  "Pixel height of the dock's text area.
This is the taller of the clock and the two stacked info lines, plus
`clock-dock-strip-padding'."
  (let* ((line (frame-char-height))
         (clock (* clock-dock-clock-height line))
         (info (* 2 clock-dock-info-height line)))
    (ceiling (+ (max clock info) clock-dock-strip-padding))))

;;; Rendering

(defun clock-dock--stop-timer ()
  "Cancel the redraw timer."
  (when clock-dock--timer
    (cancel-timer clock-dock--timer)
    (setq clock-dock--timer nil)))

(defun clock-dock--render ()
  "Redraw both dock buffers, or stop the timer if they are gone."
  (let ((clock-buf (get-buffer clock-dock--clock-buf))
        (info-buf (get-buffer clock-dock--info-buf)))
    (if (not (and (buffer-live-p clock-buf) (buffer-live-p info-buf)))
        (clock-dock--stop-timer)
      (with-current-buffer clock-buf
        (let ((inhibit-read-only t))
          (erase-buffer)
          (insert (propertize (format-time-string clock-dock-time-format)
                              'face `(:height ,clock-dock-clock-height
                                      :weight bold)))))
      (with-current-buffer info-buf
        (let ((inhibit-read-only t)
              (plain `(:height ,clock-dock-info-height)))
          (erase-buffer)
          (insert (clock-dock--line "Clocked In:"
                                    (clock-dock--task-string)
                                    (clock-dock--task-face)))
          (insert "\n")
          (insert (clock-dock--line "Timer:"
                                    (clock-dock--timer-string)
                                    plain)))))))

;;; Buffers and windows

(defun clock-dock--separator-format ()
  "Mode line format for the dock buffers: a single space, or nil for none.
The space is flattened to a thin colored line by the face remaps in
`clock-dock--prepare'."
  (when clock-dock-separator
    '(" ")))

(defun clock-dock--prepare (name)
  "Create buffer NAME with clean display settings and return it."
  (with-current-buffer (get-buffer-create name)
    (special-mode)
    (setq-local cursor-type nil
                line-spacing 0
                truncate-lines t
                vertical-scroll-bar nil
                horizontal-scroll-bar nil
                mode-line-format (clock-dock--separator-format))
    (when clock-dock-separator
      ;; Flatten the mode line faces in this buffer only.  The buffers
      ;; are killed on close, which clears these remaps.
      (dolist (f '(mode-line mode-line-active mode-line-inactive))
        (when (facep f)
          (face-remap-add-relative f :background clock-dock-line-color
                                   :foreground clock-dock-line-color
                                   :height clock-dock-separator-height
                                   :box nil :overline nil
                                   :underline nil))))
    (current-buffer)))

(defun clock-dock--windows ()
  "Return the live dock windows, or nil."
  (delq nil (list (get-buffer-window clock-dock--clock-buf)
                  (get-buffer-window clock-dock--info-buf))))

(defun clock-dock--clock-pixels ()
  "Pixel width of the big clock string, measured with its own face."
  (string-pixel-width
   (propertize (format-time-string clock-dock-time-format
                                   (encode-time 8 8 8 8 8 2008))
               'face `(:height ,clock-dock-clock-height :weight bold))))

(defun clock-dock--fit-width (win &optional exact)
  "Make the clock window WIN wide enough for its digits.
Normally this only grows the window, so you can drag the divider to
widen it.  With EXACT non-nil, also shrink it to the exact width."
  (let* ((cols (ceiling (/ (+ (clock-dock--clock-pixels)
                              clock-dock-clock-padding)
                           (frame-char-width))))
         (delta (- cols (window-total-width win))))
    (when (if exact (not (zerop delta)) (> delta 0))
      (window-resize win delta t nil nil))))

(defun clock-dock--fit-height (win)
  "Size the dock's row, through WIN, to exactly its content height."
  (let ((delta (- (clock-dock--content-pixels)
                  (window-body-height win t))))
    (unless (zerop delta)
      (window-resize win delta nil t t))))

(defun clock-dock--fit (&optional _frame)
  "Refit the dock's width and height.
Called when the dock opens and whenever window sizes change.  The
clock window is kept at least as wide as its digits, so they never
clip, and the height is kept equal to the content, so no empty space
is left under the text."
  (unless clock-dock--fitting
    (let ((clock-dock--fitting t)
          (win (get-buffer-window clock-dock--clock-buf)))
      (when (window-live-p win)
        (ignore-errors (clock-dock--fit-width win))
        (ignore-errors (clock-dock--fit-height win))))))

(defun clock-dock--teardown ()
  "Remove the dock's timer, hook, windows and buffers."
  (clock-dock--stop-timer)
  (remove-hook 'window-size-change-functions #'clock-dock--fit)
  (dolist (name (list clock-dock--clock-buf clock-dock--info-buf))
    (let ((buf (get-buffer name)))
      (when (buffer-live-p buf)
        (dolist (win (get-buffer-window-list buf nil t))
          (set-window-dedicated-p win nil)
          (ignore-errors (delete-window win)))
        (kill-buffer buf)))))

(defun clock-dock--build ()
  "Create the dock windows at the top of the main editing area."
  (let* ((clock-buf (clock-dock--prepare clock-dock--clock-buf))
         (info-buf (clock-dock--prepare clock-dock--info-buf))
         ;; The main window excludes side windows such as Treemacs, so
         ;; they keep the full height of their column.
         (top-win (split-window (window-main-window) nil 'above))
         (info-win (split-window top-win nil 'right)))
    (set-window-buffer top-win clock-buf)
    (set-window-buffer info-win info-buf)
    (dolist (win (list top-win info-win))
      (set-window-dedicated-p win t)
      (set-window-parameter win 'no-other-window t)
      (set-window-parameter win 'no-delete-other-windows t)
      (set-window-fringes win 0 0)
      (when clock-dock-hide-scroll-bars
        (set-window-scroll-bars win 0 nil 0 nil)))
    ;; The split is 50/50, so set the clock's exact width once here.
    (ignore-errors (clock-dock--fit-width top-win t))
    (clock-dock--fit)
    (add-hook 'window-size-change-functions #'clock-dock--fit)
    (clock-dock--render)
    (setq clock-dock--timer
          (run-with-timer 0 1 #'clock-dock--render))))

;;; Commands

;;;###autoload
(defun clock-dock-close ()
  "Close the clock dock."
  (interactive)
  (clock-dock--teardown))

;;;###autoload
(defun clock-dock-open ()
  "Open the clock dock at the top of the main editing area.
If opening fails, any half-built windows are removed and the error is
shown in the echo area."
  (interactive)
  (unless clock-dock--busy
    (let ((clock-dock--busy t))
      (clock-dock--teardown)
      (condition-case err
          (clock-dock--build)
        (error
         (clock-dock--teardown)
         (message "clock-dock: could not open (%s)"
                  (error-message-string err)))))))

;;;###autoload
(defun clock-dock-toggle ()
  "Open the clock dock, or close it when it is showing."
  (interactive)
  (if (clock-dock--windows)
      (clock-dock-close)
    (clock-dock-open)))

;;;###autoload
(defun clock-dock-set-timer (label)
  "Ask for a LABEL, then start an `org-timer' countdown.
The label shows on the dock only once the countdown is set.  If you
cancel, or decline to replace a running timer, the old label stays."
  (interactive "sTimer label (RET for none): ")
  (let ((new (unless (string-empty-p label) label)))
    (call-interactively #'org-timer-set-timer)
    (setq clock-dock-timer-label new)))

(provide 'clock-dock)
;;; clock-dock.el ends here
