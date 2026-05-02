(add-to-list 'load-path "~/.emacs.d/lisp")
n;;tangle test

;; setup passthrough keys
(setq w32-pass-apps-to-system nil)
(setq w32-apps-modifier 'hyper)
(setq w32-pass-lwindow-to-system nil)
(setq w32-lwindow-modifier 'super)

(setq undo-limit 50)
(global-set-key (kbd "H-.") 'org-demote-subtree)
(global-set-key (kbd "H-,") 'org-promote-subtree)

(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ;; old org link commented out for deprication 
                         ;;("org" . "https://orgmode.org/elpa/")
                         ("gnu" . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
;; clean up org package issues
(assq-delete-all 'org package--builtins)
(assq-delete-all 'org package--builtin-versions)
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package on non-Linux platforms

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(setq backup-directory-alist '(("." . "~/.emacs.d/tmp/backups/")))

(if (eq system-type 'gnu/linux)
    (use-package mu4e
      :ensure nil
      ;; :load-path "/usr/share/emacs/site-lisp/mu4e/"
      :config
      ;; this is set to t to avoid mail syncing issues
      (setq mu4e-change-filenames-when-moving t)
      ;; refresh mail using isync every 10 minutes
      (setq mu4e-update-interval (* 10 60))
      (setq mu4e-get-mail-command "mbsync -a")
      (setq mu4e-maildir "~/Mail")

      (setq mu4e-drafts-folder "/'[Gmail]'.Drafts")
      (setq mu4e-sent-folder "/[Gmail].Sent Mail")
      (setq mu4e-refile-folder "/[Gmail].All Mail")
      (setq mu4e-trash-folder "/[Gmail].Trash")

      (setq mu4e-maildir-shortcuts
            '(("/Inbox"                   . ?i)
              ("/[Gmail].Sent Mail"       . ?s)
              ("/[Gmail].Trash"           . ?t)
              ("/[Gmail].Drafts"          . ?d)
              ("/[Gmail].All Mail"        . ?a))))

  (setq
   user-mail-address "Timmymayes@gmail.com"
   user-full-name "Timothy Tyler Mayes"
   mu4e-compose-signature
   (concat
    "Best Regards,\n"
    "Tyler Mayes"))
  ;; Not working atm
  (require 'smtpmail)
  (setq message-send-mail-function 'smtpmail-send-it
        starttls-use-gnutls t
        smtpmail-starttls-credentials '(("smtp.gmail.com" 587 nil nil))
        smtpmail-auth-credentials
        '(("smtp.gmail.com" 587 "Timmymayes@gmail.com" nil))
        smtpmail-default-smtp-server "smtp.gmail.com"
        smtpmail-smtp-server "smtp.gmail.com"
        smtpmail-smtp-service 587))

(setq inhibit-startup-message t) ;inhibit start up
(scroll-bar-mode -1)   ;Disable visible scrollbar
(tool-bar-mode -1)     ;Disable toolbar
(tooltip-mode -1)      ;Disable tooltips11
(set-fringe-mode 10)   ;Give some breathing room
(menu-bar-mode -1)     ;Disable menu bar
(setq visible-bell t)  ;setup the visible bell


;; setup window splitting so its side by side usually. 
(setq split-width-threshold 80)

(set-face-attribute
 'default nil :font "Fira Code Retina" :height 140)  ; set font
(load-theme 'tango-dark)                             ; load theme
;;(desktop-save-mode 1)                                ; enable desktop saving

;; turn on hydras CONFIG-TODO: Create a Hydra Section
(use-package hydra)

;; using eshell to run bash script on startup setting up hyper and F keys
(start-process-shell-command "setup hyper" "*Messages*" "~/xmodstartup.sh")

;;set doom themes
(use-package doom-themes
  :ensure t
  :config
  ;;(load-theme 'doom-gruvbox t))
  (load-theme 'doom-sourcerer t))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :config
  ;; consider adding a mu4e alert
  (setq doom-modeline-mu4e t)
  (if (eq system-type 'gnu/linux)
      (mu4e-alert-enable-mode-line-display))
  (setq doom-modeline-height 15))


(display-time-mode) ; display time
(column-number-mode); turn on column number mode

(defun toggle-transparency ()
  "Function to toggle transparency"
  (interactive)
  (let ((alpha (frame-parameter nil 'alpha)))
    (set-frame-parameter
     nil 'alpha
     (if (eql (cond ((numberp alpha) alpha)
                    ((numberp (cdr alpha)) (cdr alpha))
                    ;; Also handle undocumented (<active> <inactive>) form.
                    ((numberp (cadr alpha)) (cadr alpha)))
              100)
         '(90 . 60) '(100 . 100)))))

;; testing if this works to set transparency to full on startup

(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(use-package which-key
  :init (which-key-mode)
  :diminish (which-key-mode)
  :config
  (setq which-key-idle-delay 1))

;;           (use-package counsel
;;             :bind (("M-x" . counsel-M-x)
;;                    ("C-x b" . counsel-ibuffer)


;; story)))

;;        (use-package ivy-richt
;;        :init
;;      (ivy-rich-mode 1))

(use-package vertico
  :ensure t
  :custom
  (vertico-cycle nil)
  (vertico-count 13)
  (vertico-resize t)
  :init
  (vertico-mode))

(use-package savehist
  :init
  (savehist-mode))

(use-package marginalia
  :after vertico
  :ensure t
  :custom
  (marginalia-max-relative-age 0)
  (marginalia-align 'center)
  (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
  :init
  (marginalia-mode))

;; turn on all the icons for completions
(use-package all-the-icons-completion
  :after(marginalia all-the-icons)
  :hook (marginalia-mode . all-the-icons-completion-marginalia-setup)
  :init
  (all-the-icons-completion-mode))
(use-package consult
  :ensure t)
(use-package consult-org-roam
  :after consult
  :ensure t)

(yas-global-mode 1)
(if (eq system-type 'windows-nt)
    (progn
      (setq yas-snippet-dirs '("c:/Users/Tyler/snippets" "~/.emacs.d/snippets" "~/snippets"))
      (yas-reload-all))
  (setq yas-snippet-dirs '("~/snippets" "~/.emacs.d/snippets"))
  )

(defhydra hydra-zoom (global-map "<f16>")
  "Zoom"
  ("+" text-scale-increase "in")
  ("=" text-scale-decrease))

(use-package ace-window)
(custom-set-faces
 '(aw-leading-char-face
   ((t (:inherit ace-jump-face-foreground :height 3.0)))))
;;

(use-package avy
  :config (progn
            (setq avy-background nil)
            (setq avy-all-windows 'all-frames)
            (setq avy-styles-alist '((avy-goto-char-2 . at)
                                     (avy-goto-char-timer . at)))))

;; function to jump to the end of a word
(defun my/avy-end()
  "run avy and jump to the end of the word. "
  (interactive)
  (progn
    (avy-goto-char-timer)
    (forward-word)))


(global-set-key (kbd "M-.") 'my/avy-end)
(global-set-key (kbd "M-,") 'avy-goto-char-timer)
(global-set-key (kbd "C-M-,") 'avy-copy-region)

(define-key isearch-mode-map (kbd "M-,") 'avy-isearch)


;; unbund c-] from abort-recursive-edit
(global-set-key (kbd "C-+") 'smartscan-symbol-go-backward)
(global-set-key (kbd "C-=") 'smartscan-symbol-go-forward)

;; Frame delete is C-H-esc


;; macros to create new frames based on monitor. 
(fset 'my/make-frame-on-asus
      (kmacro-lambda-form [?\M-x ?m ?a ?k ?e ?- ?f ?r ?a ?m ?e ?- ?o ?n ?- ?m ?o ?n ?i ?t ?o ?r return ?D ?P ?- ?0 return] 0 "%d"))

(fset 'my/make-frame-on-top-dell
      (kmacro-lambda-form [?\M-x ?m ?a ?k ?e ?- ?f ?r ?a ?m ?e ?- ?o ?n ?- ?m ?o ?n ?i ?t ?o ?r ?\C-m ?D ?P ?- ?2 ?\C-m] 0 "%d"))

(fset 'my/make-frame-on-bottom-dell
      (kmacro-lambda-form [?\M-x ?m ?a ?k ?e ?- ?f ?r ?a ?m ?e ?- ?o ?n ?- ?m ?o ?n ?i ?t ?o ?r return ?H ?D ?M ?I ?- ?0 return] 0 "%d"))


(global-set-key (kbd "C-H-1") 'my/make-frame-on-asus)
(global-set-key (kbd "C-H-2") 'my/make-frame-on-top-dell)
(global-set-key (kbd "C-H-3") 'my/make-frame-on-bottom-dell)

;;;;; Org mode setup ;;;;;

                                        ;require tempo

(defun org-mode-setup()
  (org-indent-mode)
  (variable-pitch-mode 1) 
  (auto-fill-mode 0)
  (visual-line-mode 1))

(use-package org
  :hook (org-mode . org-mode-setup)
  :bind (
         :map org-mode-map
         ("H-e" . org-narrow-to-element)
         ("C-H-e" . org-narrow-to-subtree)
         ("C-M-H-e" . org-narrow-to-block)
         ("H-o" . counsel-outline)
         ("M-s o" . my/org-occur)
         ("H-]" . 'consult-org-roam-forward-links)
         ("H-[" . 'consult-org-roam-backlinks)
         ("C-c d" . my/set-todo-ordered)
         ("C-t". org-toggle-checkbox))
  :config
  (setq org-agenda-files
        (quote ("~/Orgfiles"
                "~/Orgfiles/Productivity/goals"
                "~/Orgfiles/Productivity/review"
                )))


  (setq org-image-actual-width nil)
  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  (setq org-extend-today-until 3
        org-use-effective-time t)
  (setq org-startup-with-inline-images t)
  (setq org-ellipsis " ▾")
  (setq org-hide-emphasis-markers t)
  (setq org-agenda-window-setup 'current-window)
  (setq org-use-speed-commands t)      
  (setq org-apture-babel-evaluate t)
  (setq org-todo-keywords
        ;; need to add in "Someday Maybe status"
        (quote ((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)")
                (sequence "WAITING(w@/!)" "HOLD(h@/!)" "|" "CANCELLED(c@/!)" "PHONE" "MEETING"))))

  (setq org-todo-keyword-faces
        (quote (("TODO" :foreground "red" :weight bold)
                ("NEXT" :foreground "blue" :weight bold)
                ("DONE" :foreground "forest green" :weight bold)
                ("WAITING" :foreground "orange" :weight bold)
                ("HOLD" :foreground "magenta" :weight bold)
                ("CANCELLED" :foreground "forest green" :weight bold)
                ("MEETING" :foreground "forest green" :weight bold)
                ("PHONE" :foreground "forest green" :weight bold))))

  (setq org-todo-state-tags-triggers
        (quote (("CANCELLED" ("CANCELLED" . t))
                ("WAITING" ("WAITING" . t)) 
                ("HOLD" ("WAITING") ("HOLD" . t))
                (done ("WAITING") ("HOLD"))
                ("TODO" ("WAITING") ("CANCELLED") ("HOLD"))
                ("NEXT" ("WAITING") ("CANCELLED") ("HOLD"))
                ("DONE" ("WAITING") ("CANCELLED") ("HOLD")))))

  ;; s-Left & s-Right moves status
  (setq org-treat-S-cursor-todo-selection-as-state-change nil)

  (setq org-global-properties
        '(("Effort_All" . "0 0:10 0:15 0:45 0:30 1:00 2:00 3:00 4:00")))

                                        ; org capture

  (setq org-capture-templates
        '(
          ("t" "Tasks/Projects")
          ("tt" "Task" entry (file "~/Orgfiles/refile.org")
           "* TODO %?\n:PROPERTIES:\n:CATEGORY: Task\n:END:\n %U\n %a\n %i " :empty-lines 1)
          ("tp" "Project" entry (file "~/Orgfiles/refile.org")
           "* TODO %?\n:PROPERTIES:\n:CATEGORY: Project\n:END:\n %U\n %a\n %i " :empty-lines 1)

          ("m" "Meeting" entry (file "~/Orgfiles/refile.org")
           "* MEETING with %? :MEETING:\n%U" :clock-in t :clock-resume t :jump-to-captured t)
          ("p" "Phone call" entry (file "~/Orgfiles/refile.org")
           "* PHONE %? :PHONE:\n%U" :clock-in t :clock-resume t :jump-to-captured t)
          ("n" "note" entry (file "~/Orgfiles/refile.org")
           "* %? :NOTE:\n%u\n%a\n %i" :empty-lines 1)
          ("r" "reminder" entry (file "~/Orgfiles/refile.org")
           "* %? :REMINDER:\n %^T \n %U\n %a\n%i" :empty-lines 1)
          ("!" "recurring reminder" entry (file "~/Orgfiles/refile.org")
           "* %? :REMINDER:\n %U\n <%\\%(memq (calendar-day-of-week date) '(1 2 3 4 5))>  \n%a\n%i" :empty-lines 1)
          ("d" "Daily Metrics")
          ("dm" "Morning Metrics" table-line (file+headline "~/Orgfiles/metrics.org" "Morning")
           "| %^{Day} | %^{Weight} | %^{BP SYS} | %^{BP DIA}| %^{Sleep Time} | %^{AHI} | %^{Mood} | " :kill-buffer t)
          ("de" "Evening Metrics" table-line (file+headline "~/Orgfiles/metrics.org" "Evening")
           "| %^{Day} | %^{Output} | %^{On Schedule} | %^{Mood}| " :kill-buffer t)
          ("di" "Daily Improvement" item (file+headline "~/Orgfiles/metrics.org" "Improvements List")
           "- %?")
          ("df" "Food Log" entry (file+datetree "~/Orgfiles/FoodLog.org")
           "* %?")
          ("h" "Habit" entry (file "~/Orgfiles/habits.org")
           "* TODO %? %^g\n%U\n %a\n%i %^{STYLE|habit}p" :empty-lines 1)
          ("g" "Goal")
          (
           "gv"     ;key
           "Goal"  ; description
           entry   ; type  
           (file "~/Orgfiles/refile.org") ; target
           "* ~%^{Goal}~ :VALUE:\n:PROPERTIES:\n:created: %u\n:END:\n:LINKS:\n:END: %^{custom_id}p"
           :prepend t ; prepend properties
           :created t ;

           )
          (
           "go"     ;key
           "Outcome"  ; description
           entry   ; type  
           (file "~/Orgfiles/refile.org") ; target
           "* %^{Goal} [/] :OUTCOME:\n:PROPERTIES:\n:created: %u\n:END:\n:LINKS:\n:goal:\n:habit:\n:project:\n:END: %^{timeline}p %^{custom_id}p"
           :prepend t ; prepend properties
           :created t ;
           )
          )))

;; setup org mode map

; hotkey bindings
  (define-key global-map (kbd "C-c c")
    (lambda () (interactive) (org-capture)))

  (define-key global-map (kbd "C-c t")
    (lambda () (interactive) (org-capture nil "tt")))
  (define-key global-map (kbd "C-c ")
    (lambda () (interactive) (org-capture nil "tp")))


  (define-key global-map (kbd "C-c m")
    (lambda () (interactive) (org-capture nil "m")))

  (global-set-key (kbd "C-c a") 'org-agenda)
  (global-set-key (kbd "<f5>") 'toggle-next-task-display)
  ;; promote and demote trees using hyper
  (global-set-key (kbd "H-i") 'org-toggle-inline-images)  


                                          ; refile targets

  (setq org-refile-targets (quote ((nil :maxlevel . 9)
                                   (org-agenda-files :maxlevel . 9))))

                                          ; Use full outline paths for refile targets - we file directly with IDO
  (setq org-refile-use-outline-path t)

                                          ; Targets complete directly with IDO
  (setq org-outline-path-complete-in-steps nil)

                                          ; Allow refile to create parent tasks with confirmation
  (setq org-refile-allow-creating-parent-nodes (quote confirm))

                                          ; Use IDO for both buffer and file completion and ido-everywhere to t

                                   ;;;; Refile settings
                                          ; Exclude DONE state tasks from refile targets
  (defun bh/verify-refile-target ()
    "Exclude todo keywords with a done state from refile targets"
    (not (member (nth 2 (org-heading-components)) org-done-keywords)))

  (setq org-refile-target-verify-function 'bh/verify-refile-target)

  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit)
  (setq org-habit-graph-column 50)
  (setq org-habit-preceding-days 53)

  (add-to-list  'org-src-lang-modes '("plantuml" . plantuml))
  (setq org-plantuml-jar-path "C:/Users/tyler/AppData/Roaming")
  (global-set-key (kbd "C-c b") 'org-switchb)
  (global-set-key (kbd "C-c l") 'org-store-link)
  (global-set-key (kbd "C-c H-a") 'org-archive-subtree)

                                         ;;;;; end org mode setup ;;;;;

                                         ;;;;;;; Org Agenda Setup ;;;;;;;;;
  ;; Do not dim blocked tasks
  (setq org-agenda-dim-blocked-tasks nil)
  (add-hook 'org-agenda-finalize-hook #'hl-line-mode)

  ;; Compact the block agenda view
  (setq org-agenda-compact-blocks t)
  ;; start norang agenda view

  ;; variable setup

  ;; disable value goals from being inherited
  (setq org-tags-exclude-from-inheritance '("VALUE" "NOTE" "Q1" "Q2" "Q3" "Q4"))
  ;;reverse note order disabled
  (setq org-reverse-note-order nil)
  ;; Leading 0 for military time
  (setq org-agenda-time-leading-zero t)
  ;; sticky agendas
  (setq org-agenda-sticky t)
  ;; Enforce Dependencies
  (setq org-enforce-todo-dependencies t)
  ;; Start with log mode disabled
  (setq org-agenda-start-with-log-mode nil)
  ;; setup 5 degrees of priority
  (setq org-lowest-priority ?E)
  ;; number of seperators to 0
  (setq org-cycle-seperator-lines 0)
  ;; Remove completed deadline tasks from the agenda view
  (setq org-agenda-skip-deadline-if-done t)
  ;; Remove completed scheduled tasks from the agenda view
  (setq org-agenda-skip-scheduled-if-done t)
  ;; Remove completed items from search results
  (setq org-agenda-skip-timestamp-if-done t)
  ;; Setup Time Grid
  (setq org-agenda-time-grid
        (quote ((daily today require-timed)
                (500 600 700 800 900 1000 1100 1200 1300 1400 1500 1600 1700 1800 1900 2000 2100 2200 2300)
                "......" "------------")))
  ;;search archives
  (setq org-agenda-text-search-extra-files (quote (agenda-archives)))
  ;; honor ignore options
  (setq org-agenda-tags-todo-honor-ignore-options t)

  ;; Remove empty LOGBOOK drawers on clock out
  ;; (defun bh/remove-empty-drawer-on-clock-out ()
  ;;   (interactive)
  ;;   (save-excursion
  ;;     (beginning-of-line 0)
  ;;     (org-remove-empty-drawer-at "LOGBOOK" (point))))

  ;; (add-hook 'org-clock-out-hook 'bh/remove-empty-drawer-on-clock-out 'append)

  (defun my/org-auto-exclude-function (tag)
    "Automatic task exclusion i the agenda with / RET"
    (and (cond
          ((string= tag "REVIEW")
           t)
          ((string= tag "CONFIG")))
         (concat "-" tag)))

  (setq org-agenda-auto-exclude-function 'my/org-auto-exclude-function)

(fset 'my/set-todo-ordered
   (kmacro-lambda-form [?\C-c ?\C-x ?p ?\C-n ?\C-n ?O ?r ?d ?e ?r ?e ?d return ?1 return] 0 "%d"))

;; Jumping Macro Definitions

(fset 'my/org-agenda-jump-to-stuck-projects
      (kmacro-lambda-form [?\M-< ?\C-s ?S ?t ?u ?c ?k ?  ?P ?r ?o ?j ?e ?c ?t ?s return ?\C-a] 0 "%d"))

(fset 'my/org-agenda-jump-to-projects
      (kmacro-lambda-form [?\M-< ?\C-s ?P ?r ?o ?j ?e ?c ?t ?s ?\C-s return ?\M-b] 0 "%d"))

(fset 'my/org-agenda-jump-to-project-next-tasks
      (kmacro-lambda-form [?\M-< ?\C-s ?P ?r ?o ?j ?e ?c ?t ?  ?N ?e ?x ?t ?  ?T ?a ?s ?k ?s return ?\C-a] 0 "%d"))

(fset 'my/org-agenda-jump-to-standalone-tasks
      (kmacro-lambda-form [?\M-< ?\C-s ?S ?t ?a ?n ?d ?a ?l ?o ?n ?e ?  ?T ?a ?s ?k ?s return ?\C-a] 0 "%d"))

(fset 'my/org-agenda-jump-to-project-subtasks
      (kmacro-lambda-form [?\M-< ?\C-s ?P ?r ?o ?j ?e ?c ?t ?  ?S ?u ?b ?t ?a ?s ?k ?s return ?\C-a] 0 "%d"))

(fset 'my/org-agenda-jump-to-waiting-and-postponed-tasks
      (kmacro-lambda-form [?\M-< ?\C-s ?W ?a ?i ?t ?i ?n ?g ?  ?a ?n ?d ?  ?P ?o ?s ?t ?p ?o ?n ?e ?d ?  ?T ?a ?s ?k ?s return ?\C-a] 0 "%d"))
(fset 'my/org-agenda-jump-to-tasks-to-archive
      (kmacro-lambda-form [?\M-< ?\C-s ?T ?a ?s ?k ?s ?  ?t ?o ?  ?A ?r ?c ?h ?i ?v ?e return ?\C-a] 0 "%d"))
(fset 'my/org-agenda-jump-to-tasks-to-refile
      (kmacro-lambda-form [?\M-< ?\C-s ?T ?a ?s ?k ?s ?  ?t ?o ?  ?R ?e ?f ?i ?l ?e return ?\C-a] 0 "%d"))


(fset 'my/org-make-list-todos
      (kmacro-lambda-form [return ?\C-e return ?\C-p ?\C-a ?* ?  delete ?T ?O ?D ?\S-  backspace ?o ?\S-  backspace backspace ?O ?\S-  ?\C-c ?\C-x ?p ?C ?A ?T ?E ?G ?O ?R ?Y return ?T ?a ?s ?k return ?\C-n ?\C-n ?\C-c ?! return ?\C-n ?\C-a] 0 "%d"))


(defun my/org-convert-list-into-todos()
  "Macro expansion for repeat key"
  (interactive)
  (my/org-make-list-todos)
  (set-temporary-overlay-map
   (let ((map (make-sparse-keymap)))
     (define-key map (kbd "t") 'my/org-convert-list-into-todos)
     map)))



;; keybinds
(define-key org-agenda-mode-map (kbd "C-j s") 'my/org-agenda-jump-to-stuck-projects)
(define-key org-agenda-mode-map (kbd "C-j p") 'my/org-agenda-jump-to-projects)
(define-key org-agenda-mode-map (kbd "C-j n") 'my/org-agenda-jump-to-project-next-tasks)
(define-key org-agenda-mode-map (kbd "C-j t") 'my/org-agenda-jump-to-standalone-tasks)
(define-key org-agenda-mode-map (kbd "C-j u") 'my/org-agenda-jump-to-project-subtasks)
(define-key org-agenda-mode-map (kbd "C-j w") 'my/org-agenda-jump-to-waiting-and-postponed-tasks)
(define-key org-agenda-mode-map (kbd "C-j a") 'my/org-agenda-jump-to-tasks-to-archive)
(define-key org-agenda-mode-map (kbd "C-j r") 'my/org-agenda-jump-to-tasks-to-refile)
(global-set-key  (kbd "H-c t") 'my/org-convert-list-into-todos)

;; goto-entry macro definitions
(fset 'my/org-agenda-zoom-to-entry
      (kmacro-lambda-form [tab ?\H-e] 0 "%d"))

(fset 'my/org-agenda-view-entry-narrowed
      (kmacro-lambda-form [?  ?\C-x ?o ?\H-e ?\C-x ?o] 0 "%d"))

(define-key org-agenda-mode-map (kbd "<C-tab>") 'my/org-agenda-zoom-to-entry)
(define-key org-agenda-mode-map (kbd "C-o") 'my/org-agenda-view-entry-narrowed)

(setq org-agenda-custom-commands
      (quote (("n" "Notes" tags "NOTE"
               ((org-agenda-overriding-header "Notes")
                (org-tags-match-list-sublevels t)))
              ("h" "Habits" tags-todo "STYLE=\"habit\""
               ((org-agenda-overriding-header "Habits")
                (org-agenda-sorting-strategy
                 '(todo-state-down effort-up category-keep))))
              ("r" "Weekly Review Rollup" tags "Accomplishment|Disappointment"
               ((org-agenda-overriding-header "Accomplishments & Disappointments")
                (org-tags-match-list-sublevels 'indented)))
              ( "d" "Daily Agenda" ((agenda ""
                                            ((org-agenda-span 1))
                                            ))
                )
              ( "w" "Weekly Agenda" ((agenda ""
                                            ((org-agenda-span 7))
                                            ))
                )                
              ("p" "Personal Agenda"
               ((agenda "" nil)
                (tags-todo "-CANCELLED/!"
                           ((org-agenda-overriding-header "Stuck Projects")
                            (org-agenda-skip-function 'bh/skip-non-stuck-projects)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-HOLD-CANCELLED/!"
                           ((org-agenda-overriding-header "Projects")
                            (org-agenda-skip-function 'bh/skip-non-projects)
                            (org-tags-match-list-sublevels 'indented)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-CANCELLED/!NEXT"
                           ((org-agenda-overriding-header (concat "Project Next Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-projects-and-habits-and-single-tasks)
                            (org-tags-match-list-sublevels t)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(todo-state-down effort-up category-keep))))
                (tags-todo "-REFILE-CANCELLED-WAITING-HOLD/!"
                           ((org-agenda-overriding-header (concat "Project Subtasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-non-project-tasks)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-REFILE-CANCELLED-WAITING-HOLD/!"
                           ((org-agenda-overriding-header (concat "Standalone Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-project-tasks)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-CANCELLED+WAITING|HOLD/!"
                           ((org-agenda-overriding-header (concat "Waiting and Postponed Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-non-tasks)
                            (org-tags-match-list-sublevels nil)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)))
                (tags "-REFILE/"
                      ((org-agenda-overriding-header "Tasks to Archive")
                       (org-agenda-skip-function 'bh/skip-non-archivable-tasks)
                       (org-tags-match-list-sublevels nil))))
               ((org-agenda-tag-filter-preset '("+PERSONAL"))))
              ("P" "Personal Project List"
               (
                (tags-todo "-CANCELLED/!"
                           ((org-agenda-overriding-header "Personal Project List\n---------------------\nStuck Projects")
                            (org-agenda-skip-function 'bh/skip-non-stuck-projects)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-HOLD-CANCELLED/!"
                           ((org-agenda-overriding-header "Projects")
                            (org-agenda-skip-function 'bh/skip-non-projects)
                            (org-tags-match-list-sublevels 'indented)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-CANCELLED/!NEXT"
                           ((org-agenda-overriding-header (concat "Project Next Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-projects-and-habits-and-single-tasks)
                            (org-tags-match-list-sublevels t)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(todo-state-down effort-up category-keep))))
                (tags-todo "-REFILE-CANCELLED-WAITING-HOLD/!"
                           ((org-agenda-overriding-header (concat "Project Subtasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-non-project-tasks)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-REFILE-CANCELLED-WAITING-HOLD/!"
                           ((org-agenda-overriding-header (concat "Standalone Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-project-tasks)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-CANCELLED+WAITING|HOLD/!"
                           ((org-agenda-overriding-header (concat "Waiting and Postponed Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-non-tasks)
                            (org-tags-match-list-sublevels nil)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)))
                (tags "-REFILE/"
                      ((org-agenda-overriding-header "Tasks to Archive")
                       (org-agenda-skip-function 'bh/skip-non-archivable-tasks)
                       (org-tags-match-list-sublevels nil))))
               ((org-agenda-tag-filter-preset '("+PERSONAL"))))                
              ("C" "Config Project List"
               ((tags-todo "-CANCELLED/!"
                           ((org-agenda-overriding-header "Config Project List\n-------------------\nStuck Projects")
                            (org-agenda-skip-function 'bh/skip-non-stuck-projects)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-HOLD-CANCELLED/!"
                           ((org-agenda-overriding-header "Projects")
                            (org-agenda-skip-function 'bh/skip-non-projects)
                            (org-tags-match-list-sublevels 'indented)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-CANCELLED/!NEXT"
                           ((org-agenda-overriding-header (concat "Project Next Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-projects-and-habits-and-single-tasks)
                            (org-tags-match-list-sublevels t)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(todo-state-down effort-up category-keep))))
                (tags-todo "-REFILE-CANCELLED-WAITING-HOLD/!"
                           ((org-agenda-overriding-header (concat "Project Subtasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-non-project-tasks)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-REFILE-CANCELLED-WAITING-HOLD/!"
                           ((org-agenda-overriding-header (concat "Standalone Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-project-tasks)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-CANCELLED+WAITING|HOLD/!"
                           ((org-agenda-overriding-header (concat "Waiting and Postponed Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-non-tasks)
                            (org-tags-match-list-sublevels nil)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)))
                (tags "-REFILE/"
                      ((org-agenda-overriding-header "Tasks to Archive")
                       (org-agenda-skip-function 'bh/skip-non-archivable-tasks)
                       (org-tags-match-list-sublevels nil))))
               ((org-agenda-tag-filter-preset '("+CONFIG"))))
              ("c" "Config Agenda"
               ((agenda "" nil)
                (tags-todo "-CANCELLED/!"
                           ((org-agenda-overriding-header "Stuck Projects")
                            (org-agenda-skip-function 'bh/skip-non-stuck-projects)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-HOLD-CANCELLED/!"
                           ((org-agenda-overriding-header "Projects")
                            (org-agenda-skip-function 'bh/skip-non-projects)
                            (org-tags-match-list-sublevels 'indented)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-CANCELLED/!NEXT"
                           ((org-agenda-overriding-header (concat "Project Next Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-projects-and-habits-and-single-tasks)
                            (org-tags-match-list-sublevels t)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(todo-state-down effort-up category-keep))))
                (tags-todo "-REFILE-CANCELLED-WAITING-HOLD/!"
                           ((org-agenda-overriding-header (concat "Project Subtasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-non-project-tasks)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-REFILE-CANCELLED-WAITING-HOLD/!"
                           ((org-agenda-overriding-header (concat "Standalone Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-project-tasks)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-CANCELLED+WAITING|HOLD/!"
                           ((org-agenda-overriding-header (concat "Waiting and Postponed Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-non-tasks)
                            (org-tags-match-list-sublevels nil)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)))
                (tags "-REFILE/"
                      ((org-agenda-overriding-header "Tasks to Archive")
                       (org-agenda-skip-function 'bh/skip-non-archivable-tasks)
                       (org-tags-match-list-sublevels nil))))
               ((org-agenda-tag-filter-preset '("+CONFIG"))))                
              ("o" "Office Agenda"
               ((agenda "" nil)
                (tags-todo "-CANCELLED/!"
                           ((org-agenda-overriding-header "Stuck Projects")
                            (org-agenda-skip-function 'bh/skip-non-stuck-projects)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-HOLD-CANCELLED/!"
                           ((org-agenda-overriding-header "Projects")
                            (org-agenda-skip-function 'bh/skip-non-projects)
                            (org-tags-match-list-sublevels 'indented)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-CANCELLED/!NEXT"
                           ((org-agenda-overriding-header (concat "Project Next Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-projects-and-habits-and-single-tasks)
                            (org-tags-match-list-sublevels t)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(todo-state-down effort-up category-keep))))
                (tags-todo "-REFILE-CANCELLED-WAITING-HOLD/!"
                           ((org-agenda-overriding-header (concat "Project Subtasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-non-project-tasks)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-REFILE-CANCELLED-WAITING-HOLD/!"
                           ((org-agenda-overriding-header (concat "Standalone Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-project-tasks)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-CANCELLED+WAITING|HOLD/!"
                           ((org-agenda-overriding-header (concat "Waiting and Postponed Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-non-tasks)
                            (org-tags-match-list-sublevels nil)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)))
                (tags "-REFILE/"
                      ((org-agenda-overriding-header "Tasks to Archive")
                       (org-agenda-skip-function 'bh/skip-non-archivable-tasks)
                       (org-tags-match-list-sublevels nil))))
               ((org-agenda-tag-filter-preset '("+SEAS"))))
              ("O" "Office Project List"
               (
                (tags-todo "-CANCELLED/!"
                           ((org-agenda-overriding-header "Office Project List\n--------------------\nStuck Projects")
                            (org-agenda-skip-function 'bh/skip-non-stuck-projects)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-HOLD-CANCELLED/!"
                           ((org-agenda-overriding-header "Projects")
                            (org-agenda-skip-function 'bh/skip-non-projects)
                            (org-tags-match-list-sublevels 'indented)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-CANCELLED/!NEXT"
                           ((org-agenda-overriding-header (concat "Project Next Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-projects-and-habits-and-single-tasks)
                            (org-tags-match-list-sublevels t)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(todo-state-down effort-up category-keep))))
                (tags-todo "-REFILE-CANCELLED-WAITING-HOLD/!"
                           ((org-agenda-overriding-header (concat "Project Subtasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-non-project-tasks)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-REFILE-CANCELLED-WAITING-HOLD/!"
                           ((org-agenda-overriding-header (concat "Standalone Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-project-tasks)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-CANCELLED+WAITING|HOLD/!"
                           ((org-agenda-overriding-header (concat "Waiting and Postponed Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-non-tasks)
                            (org-tags-match-list-sublevels nil)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)))
                (tags "-REFILE/"
                      ((org-agenda-overriding-header "Tasks to Archive")
                       (org-agenda-skip-function 'bh/skip-non-archivable-tasks)
                       (org-tags-match-list-sublevels nil))))
               ((org-agenda-tag-filter-preset '("+SEAS"))))                
              (" " "Agenda"
               ((agenda "" nil)
                (tags "REFILE"
                      ((org-agenda-overriding-header "Tasks to Refile")
                       (org-tags-match-list-sublevels nil)))
                (tags-todo "-CANCELLED/!"
                           ((org-agenda-overriding-header "Stuck Projects")
                            (org-agenda-skip-function 'bh/skip-non-stuck-projects)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-HOLD-CANCELLED/!"
                           ((org-agenda-overriding-header "Projects")
                            (org-agenda-skip-function 'bh/skip-non-projects)
                            (org-tags-match-list-sublevels 'indented)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-CANCELLED/!NEXT"
                           ((org-agenda-overriding-header (concat "Project Next Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-projects-and-habits-and-single-tasks)
                            (org-tags-match-list-sublevels t)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(todo-state-down effort-up category-keep))))
                (tags-todo "-REFILE-CANCELLED-WAITING-HOLD/!"
                           ((org-agenda-overriding-header (concat "Project Subtasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-non-project-tasks)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-REFILE-CANCELLED-WAITING-HOLD/!"
                           ((org-agenda-overriding-header (concat "Standalone Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-project-tasks)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-CANCELLED+WAITING|HOLD/!"
                           ((org-agenda-overriding-header (concat "Waiting and Postponed Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-non-tasks)
                            (org-tags-match-list-sublevels nil)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)))
                (tags "-REFILE/"
                      ((org-agenda-overriding-header "Tasks to Archive")
                       (org-agenda-skip-function 'bh/skip-non-archivable-tasks)
                       (org-tags-match-list-sublevels nil))))
               nil))))

;; start norang helpers

(defun bh/skip-non-archivable-tasks ()
  "Skip trees that are not available for archiving"
  (save-restriction
    (widen)
    ;; Consider only tasks with done todo headings as archivable candidates
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max))))
          (subtree-end (save-excursion (org-end-of-subtree t))))
      (if (member (org-get-todo-state) org-todo-keywords-1)
          (if (member (org-get-todo-state) org-done-keywords)
              (let* ((daynr (string-to-number (format-time-string "%d" (current-time))))
                     (a-month-ago (* 60 60 24 (+ daynr 1)))
                     (last-month (format-time-string "%Y-%m-" (time-subtract (current-time) (seconds-to-time a-month-ago))))
                     (this-month (format-time-string "%Y-%m-" (current-time)))
                     (subtree-is-current (save-excursion
                                           (forward-line 1)
                                           (and (< (point) subtree-end)
                                                (re-search-forward (concat last-month "\\|" this-month) subtree-end t)))))
                (if subtree-is-current
                    subtree-end ; Has a date in this month or last month, skip it
                  nil))  ; available to archive
            (or subtree-end (point-max)))
        next-headline))))  



(defun bh/find-project-task ()
  "Move point to the parent (project) task if any"
  (save-restriction
    (widen)
    (let ((parent-task (save-excursion (org-back-to-heading 'invisible-ok) (point))))
      (while (org-up-heading-safe)
        (when (member (nth 2 (org-heading-components)) org-todo-keywords-1)
          (setq parent-task (point))))
      (goto-char parent-task)
      parent-task)))


(defun bh/is-project-p ()
  "Any task with a todo keyword subtask"
  (save-restriction
    (widen)
    (let ((has-subtask)
          (subtree-end (save-excursion (org-end-of-subtree t)))
          (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
      (save-excursion
        (forward-line 1)
        (while (and (not has-subtask)
                    (< (point) subtree-end)
                    (re-search-forward "^\*+ " subtree-end t))
          (when (member (org-get-todo-state) org-todo-keywords-1)
            (setq has-subtask t))))
      (and is-a-task has-subtask))))

(defun bh/is-project-subtree-p ()
  "Any task with a todo keyword that is in a project subtree.
           Callers of this function already widen the buffer view."
  (let ((task (save-excursion (org-back-to-heading 'invisible-ok)
                              (point))))
    (save-excursion
      (bh/find-project-task)
      (if (equal (point) task)
          nil
        t))))

(defun bh/is-task-p ()
  "Any task with a todo keyword and no subtask"
  (save-restriction
    (widen)
    (let ((has-subtask)
          (subtree-end (save-excursion (org-end-of-subtree t)))
          (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
      (save-excursion
        (forward-line 1)
        (while (and (not has-subtask)
                    (< (point) subtree-end)
                    (re-search-forward "^\*+ " subtree-end t))
          (when (member (org-get-todo-state) org-todo-keywords-1)
            (setq has-subtask t))))
      (and is-a-task (not has-subtask)))))

(defun bh/is-subproject-p ()
  "Any task which is a subtask of another project"
  (let ((is-subproject)
        (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
    (save-excursion
      (while (and (not is-subproject) (org-up-heading-safe))
        (when (member (nth 2 (org-heading-components)) org-todo-keywords-1)
          (setq is-subproject t))))
    (and is-a-task is-subproject)))

(defun bh/list-sublevels-for-projects-indented ()
  "Set org-tags-match-list-sublevels so when restricted to a subtree we list all subtasks.
             This is normally used  skipping functions where this variable is already local to the agenda."
  (if (marker-buffer org-agenda-restrict-begin)
      (setq org-tags-match-list-sublevels 'indented)
    (setq org-tags-match-list-sublevels nil))
  nil)

(defun bh/list-sublevels-for-projects ()
  "Set org-tags-match-list-sublevels so when restricted to a subtree we list all subtasks.
             This is normally used by skipping functions where this variable is already local to the agenda."
  (if (marker-buffer org-agenda-restrict-begin)
      (setq org-tags-match-list-sublevels t)
    (setq org-tags-match-list-sublevels nil))
  nil)

(defvar bh/hide-scheduled-and-waiting-next-tasks t)

(defun toggle-next-task-display ()
  (interactive)
  (setq bh/hide-scheduled-and-waiting-next-tasks (not bh/hide-scheduled-and-waiting-next-tasks))
  (when  (equal major-mode 'org-agenda-mode)
    (org-agenda-redo))
  (message "%s WAITING and SCHEDULED NEXT Tasks" (if bh/hide-scheduled-and-waiting-next-tasks "Hide" "Show")))

(defun bh/skip-stuck-projects ()
  "Skip trees that are not stuck projects"
  (save-restriction
    (widen)
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
      (if (bh/is-project-p)
          (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
                 (has-next ))
            (save-excursion
              (forward-line 1)
              (while (and (not has-next) (< (point) subtree-end) (re-search-forward "^\\*+ NEXT " subtree-end t))
                (unless (member "WAITING" (org-get-tags-at))
                  (setq has-next t))))
            (if has-next
                nil
              next-headline)) ; a stuck project, has subtasks but no next task
        nil))))

(defun bh/skip-non-stuck-projects ()
  "Skip trees that are not stuck projects"
  ;; (bh/list-sublevels-for-projects-indented)
  (save-restriction
    (widen)
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
      (if (bh/is-project-p)
          (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
                 (has-next ))
            (save-excursion
              (forward-line 1)
              (while (and (not has-next) (< (point) subtree-end) (re-search-forward "^\\*+ NEXT " subtree-end t))
                (unless (member "WAITING" (org-get-tags-at))
                  (setq has-next t))))
            (if has-next
                next-headline
              nil)) ; a stuck project, has subtasks but no next task
        next-headline))))

(defun bh/skip-non-projects ()
  "Skip trees that are not projects"
  ;; (bh/list-sublevels-for-projects-indented)
  (if (save-excursion (bh/skip-non-stuck-projects))
      (save-restriction
        (widen)
        (let ((subtree-end (save-excursion (org-end-of-subtree t))))
          (cond
           ((bh/is-project-p)
            nil)
           ((and (bh/is-project-subtree-p) (not (bh/is-task-p)))
            nil)
           (t
            subtree-end))))
    (save-excursion (org-end-of-subtree t))))

(defun bh/skip-non-tasks ()
  "Show non-project tasks.
           Skip project and sub-project tasks, habits, and project related tasks."
  (save-restriction
    (widen)
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
      (cond
       ((bh/is-task-p)
        nil)
       (t
        next-headline)))))

(defun bh/skip-project-trees-and-habits ()
  "Skip trees that are projects"
  (save-restriction
    (widen)
    (let ((subtree-end (save-excursion (org-end-of-subtree t))))
      (cond
       ((bh/is-project-p)
        subtree-end)
       ((org-is-habit-p)
        subtree-end)
       (t
        nil)))))

(defun bh/skip-projects-and-habits-and-single-tasks ()
  "Skip trees that are projects, tasks that are habits, single non-project tasks"
  (save-restriction
    (widen)
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
      (cond
       ((org-is-habit-p)
        next-headline)
       ((and bh/hide-scheduled-and-waiting-next-tasks
             (member "WAITING" (org-get-tags-at)))
        next-headline)
       ((bh/is-project-p)
        next-headline)
       ((and (bh/is-task-p) (not (bh/is-project-subtree-p)))
        next-headline)
       (t
        nil)))))

(defun bh/skip-project-tasks-maybe ()
  "Show tasks related to the current restriction.
           When restricted to a project, skip project and sub project tasks, habits, NEXT tasks, and loose tasks.
           When not restricted, skip project and sub-project tasks, habits, and project related tasks."
  (save-restriction
    (widen)
    (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
           (next-headline (save-excursion (or (outline-next-heading) (point-max))))
           (limit-to-project (marker-buffer org-agenda-restrict-begin)))
      (cond
       ((bh/is-project-p)
        next-headline)
       ((org-is-habit-p)
        subtree-end)
       ((and (not limit-to-project)
             (bh/is-project-subtree-p))
        subtree-end)
       ((and limit-to-project
             (bh/is-project-subtree-p)
             (member (org-get-todo-state) (list "NEXT")))
        subtree-end)
       (t
        nil)))))

(defun bh/skip-project-tasks ()
  "Show non-project tasks.
           Skip project and sub-project tasks, habits, and project related tasks."
  (save-restriction
    (widen)
    (let* ((subtree-end (save-excursion (org-end-of-subtree t))))
      (cond
       ((bh/is-project-p)
        subtree-end)
       ((org-is-habit-p)
        subtree-end)
       ((bh/is-project-subtree-p)
        subtree-end)
       (t
        nil)))))

(defun bh/skip-non-project-tasks ()
  "Show project tasks.
           Skip project and sub-project tasks, habits, and loose non-project tasks."
  (save-restriction
    (widen)
    (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
           (next-headline (save-excursion (or (outline-next-heading) (point-max)))))
      (cond
       ((bh/is-project-p)
        next-headline)
       ((org-is-habit-p)
        subtree-end)
       ((and (bh/is-project-subtree-p)
             (member (org-get-todo-state) (list "NEXT")))
        subtree-end)
       ((not (bh/is-project-subtree-p))
        subtree-end)
       (t
        nil)))))

(defun bh/skip-projects-and-habits ()
  "Skip trees that are projects and tasks that are habits"
  (save-restriction
    (widen)
    (let ((subtree-end (save-excursion (org-end-of-subtree t))))
      (cond
       ((bh/is-project-p)
        subtree-end)
       ((org-is-habit-p)
        subtree-end)
       (t
        nil)))))

(defun bh/skip-non-subprojects ()
  "Skip trees that are not projects"
  (let ((next-headline (save-excursion (outline-next-heading))))
    (if (bh/is-subproject-p)
        nil
      next-headline)))

;; Agenda Sorting




;; End norang agenda setup



;; setup v-align mode for tables
(use-package valign)
(add-hook 'org-mode-hook #'valign-mode)

(dolist (face '((org-level-1 . 1.2)
                (org-level-2 . 1.1)
                (org-level-3 . 1.05)
                (org-level-4 . 1.0)
                (org-level-5 . 1.1)
                (org-level-6 . 1.1)
                (org-level-7 . 1.1)
                (org-level-8 . 1.1)))
  (set-face-attribute (car face) nil :font "Cantarell" :weight 'regular :height (cdr face)))
                                        ; keep a few things fixed pitch as they should be for line ups

(set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
(set-face-attribute 'org-table nil  :inherit 'fixed-pitch)
(set-face-attribute 'org-formula nil  :inherit 'fixed-pitch)
(set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
                                        ;  (set-face-attribute 'org-indent nil :inherit '(org-hide fixed-pitch))
(set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
(set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
(set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
(set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch)
;;font lock modes
(require 'font-lock)
(all-the-icons-completion-mode 1)

(use-package org-bullets
    :after org
    :hook (org-mode . org-bullets-mode)
    :custom
    (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))


                                          ;replace dashes with dots

  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  (global-prettify-symbols-mode t)

 ; (defun my/org-buffer-setup ()
    ;; (push '("[ ]" . "☐" ) prettify-symbols-alist)
    ;; (push '("[X]" . "☑" ) prettify-symbols-alist)
    ;; (push '("[-]" . "❍" ) prettify-symbols-alist)
    ;; )

;  (add-hook 'org-mode-hook #'my/org-buffer-setup)
  ;; Override some modes which derive from the above
  (dolist (mode '(org-mode-hook))
    (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; This is needed as of Org 9.2
                                        ;  (require 'org-tempo)
                                        ;  (with-eval-after-load 'org-tempo



;; C-C C-, to use a structure template
(add-to-list 'org-structure-template-alist '("sh" . "src shell"))
(add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp")) 
(add-to-list 'org-structure-template-alist '("py" . "src python"))

(load "org-agenda-category-icons")
(org-agenda-category-icons!

 :material
 (repeat Recurring)
 (group Meeting)
 (cake Birthday)
 (cake Anniversary)
 (event Event)
 (web Website)
 (people Meeting)


 :octicon
 (tools Habit)

 :faicon
 (cogs Config)
 (check-circle Task)
 (code Odin)
 (list-ul Project)
 (phone Phone)
 (car Vehicle)
 (plus-square Health)
 (pencil-square-o Note)
 (exclamation-circle Reminder)
 (flag Holiday)
 (info Note)
 (star Goals)
 (archive Archive))

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp .t )
   (js .t)
   (shell . t)
   (dot . t)
   (plantuml . t)
   (python .t)))

;;auto tangle my emacs config file
(defun my/org-babel-tangle-config()
  (when (string-equal (buffer-file-name)
                      (expand-file-name "~/Orgfiles/configbackups/main-config.org")); might need to condituionally use this:
                                        ;(expand-file-name "c:/Users/Tyler/emacsone/OrgFiles/emacsconf.org"))
    ;; dynamic scoping
    (let ((org-onfirm-babel-evaluate nil))
      (org-babel-tangle))))
(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'my/org-babel-tangle-config)))

(defun org-mode-visual-fill()
  (setq visual-fill-column-width 110 visual-fill-column-center-text t)
  (visual-fill-column-mode 1))


(use-package visual-fill-column
  :hook (org-mode . org-mode-visual-fill))

(setq org-clock-sound "~/Downloads/cheer.wav")

(use-package org-roam
  :ensure t
  :init
  (setq org-roam-v2-act t)
  :custom
  (org-roam-directory "~/RoamNotes")
  (org-roam-completion-everywhere t)
  ( org-agenda-todo-list-sublevels nil)        

  :bind
  (("C-c n l" . org-roam-buffer-toggle)
   ("C-c n f" . org-roam-node-find)
   ("C-c n i" . org-roam-node-insert)
   ("C-c n i" . org-id-get-create)
   ("C-c n a" . org-roam-alias-add)
   ("C-c n t" . org-roam-tag-add)
   ("C-c n r" . org-roam-ref-add)
   ("C-c n s" . consult-org-roam-search)
   ("C-c n m" . my/MOC-find)
   ("C-c n x a" . org-roam-alias-remove)
   ("C-c n x r" . org-roam-ref-remove)
   ("C-c n x t" . org-roam-tag-remove)
   ("C-c n F g" . my/GAME-find)

   ("C-c n I" . org-roam-node-insert-immediate)
   :map org-mode-map
   ("C-c n b" . org-mark-ring-goto)

   :map org-roam-dailies-map
   ("Y" . org-roam-dailies-capture-yesterday)
   ("T" . org-roam-dailies-capture-tomorrow))

  :bind-keymap
  ("C-c n d" . org-roam-dailies-map)
  :config
  (require 'org-roam-dailies)
  (org-roam-db-autosync-mode))


;; for org-roam-buffer-toggle
;; Recommendation in the official manual
(add-to-list 'display-buffer-alist
             '("\\*org-roam\\*"
               (display-buffer-in-direction)
               (direction . right)
               (window-width . 0.33)
               (window-height . fit-window-to-buffer)))



;;  Bind this to C-c n In
(defun org-roam-node-insert-immediate (arg &rest args)
  (interactive "P")
  (let ((args (cons arg args))
        (org-roam-capture-templates (list (append (car org-roam-capture-templates)
                                                  '(:immediate-finish t)))))
    (apply #'org-roam-node-insert args)))  


(defun my/find-MOC-only(node)
  "find Map of Content (MOC) files only"
  (let ((tags (org-roam-node-tags node)))
    (member "MOC" tags)))


(defun my/MOC-find ()
  "Find moc files"
  (interactive)
  (org-roam-node-find t nil 'my/find-MOC-only))

(defun my/find-games-only(node)
  "Find entries tagged as games"
  (let ((tags (org-roam-node-tags node)))
    (member "Game" tags)))

(defun my/GAME-find()
  "Find game files"
  (interactive)
  (org-roam-node-find t nil 'my/find-games-only))

(with-eval-after-load "org-roam" 
  (setq org-roam-capture-templates
        '(("d" "default" plain
           "%?"
           :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+date: %U\n")
           :unnarrowed t)
          ("g" "games")
          ("ga" "Add Game" plain
           "\n* Details\n\nGame Name: ${title}\nDesigner: %^{Designer}\nYear: %^{Year}\nPublisher: %^{Publisher}\nBGG Link: %^{BGG Link}\n\n* Description\n\n* First Impression\n\n%?"
           :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title:${title}\n#+filetags: :Game:\n#+date: %U\n")
           :unnarrowed t)
          ("b" "book notes" plain
           "\n* Source\n\nAuthor: %^{Author}\nTitle: ${title}\nYear: %^{Year}\n\n* Summary\n\n%?"
           :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+date: %U\n")
           :unnarrowed t))))

(setq org-roam-mode-sections
      (list #'org-roam-backlinks-section
            #'org-roam-reflinks-section
            #'org-roam-unlinked-references-section
            ))

(setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:30}" 'face 'org-tag)))

(use-package org-roam-ui
  :bind ("C-H-4" . org-roam-ui-open)
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t))

(use-package org-remark)
(org-remark-global-tracking-mode 1)
(define-key global-map (kbd "C-c r m") #'org-remark-mark)

(with-eval-after-load 'org-remark
  (define-key org-remark-mode-map (kbd "C-c r o") #'org-remark-open) 
  (define-key org-remark-mode-map (kbd "C-c r b m") #'org-remark-mark-yellow) 
  (define-key org-remark-mode-map (kbd "C-c r b o") #'org-remark-mark-orange-bg) 
  (define-key org-remark-mode-map (kbd "C-c r b b") #'org-remark-mark-blue-bg) 
  (define-key org-remark-mode-map (kbd "C-c r b g") #'org-remark-mark-grey-bg) 
  (define-key org-remark-mode-map (kbd "C-c r b l b") #'org-remark-mark-light-blue-bg) 
  (define-key org-remark-mode-map (kbd "C-c r f o") #'org-remark-mark-orange-fg) 
  (define-key org-remark-mode-map (kbd "C-c r f c") #'org-remark-mark-cyan-fg) 
  (define-key org-remark-mode-map (kbd "C-c r f b") #'org-remark-mark-blue-fg) 
  (define-key org-remark-mode-map (kbd "C-c r f g") #'org-remark-mark-grey-fg) 
  (define-key org-remark-mode-map (kbd "C-c r f p") #'org-remark-mark-pink-fg)
  (define-key org-remark-mode-map (kbd "C-c r h o") #'org-remark-mark-orange-bg-bold)       
  (define-key org-remark-mode-map (kbd "C-c r d t") #'org-remark-mark-typo) 
  (define-key org-remark-mode-map (kbd "C-c r ]") #'org-remark-view-next) 
  (define-key org-remark-mode-map (kbd "C-c r [") #'org-remark-view-prev) 
  (define-key org-remark-mode-map (kbd "C-c r r") #'org-remark-remove))


(org-remark-create "typo"
                   '(:underline (:color "#8f0075" :style wave))
                   '(help-echo "Fix the typo"))
(org-remark-create "grey-bg"
                   '(doom-modeline-battery-normal))
(org-remark-create "orange-bg-bold"
                   '(isearch))
(org-remark-create "orange-bg"
                   '(:background "chocolate" :foreground "cornsilk"))
(org-remark-create "blue-fg"
                   '(gnus-group-mail-2))
(org-remark-create "orange-fg"
                   '(alert-high-face))
(org-remark-create "cyan-fg"
                   '(:foreground "turquoise"))
(org-remark-create "grey-fg"
                   '(file-name-shadow))
(org-remark-create "pink-fg"
                   '(gnus-group-news-4))
(org-remark-create "blue-bg"
                   '(smerge-refined-changed))
(org-remark-create "light-blue-bg"
                   '(avy-goto-char-timer-face))

(use-package org-transclusion)
(add-hook 'org-mode-hook #'org-transclusion-mode)
(fset 'my/org-transclusion-make
      (kmacro-lambda-form [?\C-  ?\C-c ?\C-n ?\M-w ?\C-p ?\C-y ?\C-c ?\C-p ?\C-c ?\C-p ?\M-x ?o ?r ?g ?- ?t ?r ?a ?n ?s ?c ?l ?u ?s ?i ?o ?n ?- ?d ?e ?a tab return ?\C-p ?\C-k] 0 "%d"))

(use-package org-present)
(eval-after-load "org-present"
  '(progn
     (add-hook 'org-present-mode-hook
               (lambda ()
                 (org-present-big)
                 (org-display-inline-images)
                 (hl-line-mode)
                 ;; (org-present-hide-cursor)
                 ;; (org-present-read-only)
                 ))

     (add-hook 'org-present-mode-quit-hook
               (lambda ()
                 (org-present-small)
                 (org-remove-inline-images)
                 (hl-line-mode)
                 ;; (org-present-show-cursor)
                 ;; (org-present-read-write)
                 ))))

(require 'calfw-org)
  (require 'calfw-cal)
  (require 'calfw-gcal)

(defun my-open-calendar ()
  (interactive)
  (cfw:open-calendar-buffer
   :contents-sources
   (list
    (cfw:org-create-file-source "SEAS" "~/Orgfiles/SEAS.org" "#a0a0a0")  ; Work orgmode source
    (cfw:org-create-file-source "Personal" "~/Orgfiles/tasks.org" "Orange") ; Personal orgmode
   )))

(use-package ledger-mode
  :ensure t
  :init
  (setq ledger-clear-whole-transactions 1)
  :bind (
         :map ledger-mode-map
         ("C-M-n" . ledger-navigate-next-uncleared)
         ("C-M-p" . ledger-navigate-previous-uncleared))
  :mode "\\.dat\\'")

(setq ledger-reports
      '(("bal"            "%(binary) -f %(ledger-file) bal")
        ("bal this month" "%(binary) -f %(ledger-file) bal -p %(month) -S amount")
        ("bal this year"  "%(binary) -f %(ledger-file) bal -p 'this year'")
        ("net worth"      "%(binary) -f %(ledger-file) bal Assets Liabilities")
        ("account"        "%(binary) -f %(ledger-file) reg %(account)")))

(use-package magit
  :commands (magit-status magit-get-current-branch)
  :bind (("s-m m" . magit-status)
         ("s-m j" . magit-dispatch)
         ("s-m k" . magit-file-dispatch)
         ("s-m l" . magit-log-buffer-file)
         ("s-m b" . magit-blame))
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))
(setq magit-clone-default-directory "~/Projects/")

;; Bindings

(use-package git-gutter
  :hook (prog-mode . git-gutter-mode)
  :config
  (setq git-gutter:update-interval 0.02))
(use-package git-gutter-fringe
  :config
  (define-fringe-bitmap 'git-gutter-fr:added [224] nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:modified [224] nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:deleted [128 192 224 240] nil nil 'bottom))

(use-package forge)

(defun ar/git-clone-clipboard-url ()
  "Clone git URL in clipboard asynchronously and open in dired when finished."
  (interactive)
  (cl-assert (string-match-p "^\\(http\\|https\\|ssh\\)://" (current-kill 0)) nil "No URL in clipboard")
  (let* ((url (current-kill 0))
         (download-dir (expand-file-name "~/Downloads/"))
         (project-dir (concat (file-name-as-directory download-dir)
                              (file-name-base url)))
         (default-directory download-dir)
         (command (format "git clone %s" url))
         (buffer (generate-new-buffer (format "*%s*" command)))
         (proc))
    (when (file-exists-p project-dir)
      (if (y-or-n-p (format "%s exists. delete?" (file-name-base url)))
          (delete-directory project-dir t)
        (user-error "Bailed")))
    (switch-to-buffer buffer)
    (setq proc (start-process-shell-command (nth 0 (split-string command)) buffer command))
    (with-current-buffer buffer
      (setq default-directory download-dir)
      (shell-command-save-pos-or-erase)
      (require 'shell)
      (shell-mode)
      (view-mode +1))
    (set-process-sentinel proc (lambda (process state)
                                 (let ((output (with-current-buffer (process-buffer process)
                                                 (buffer-string))))
                                   (kill-buffer (process-buffer process))
                                   (if (= (process-exit-status process) 0)
                                       (progn
                                         (message "finished: %s" command)
                                         (dired project-dir))
                                     (user-error (format "%s\n%s" command output))))))
    (set-process-filter proc #'comintoutput-filter)))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~/Projects/Code")
    (setq projectile-project-search-path '("~/Projects/Code")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :config (counsel-projectile-mode))

(global-set-key (kbd "H-x H-s") 'projectile-save-project-buffers)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(add-hook 'prog-mode-hook 'electric-pair-mode)
(add-hook 'prog-mode-hook 'electric-indent-mode)
(global-set-key (kbd "C-c s (") 'electric-pair-mode)

(setq display-line-numbers-type 'relative)

;; (defun my-display-numbers-hook ()
;;   (display-line-numbers-mode t)
;; (add-hook 'prog-mode-hook 'my-display-numbers-hook)
;; (add-hook 'text-mode-hook 'my-display-numbers-hook)
;; (dolist (mode '(org-mode-hook))
;;   (add-hook mode (lambda () (display-line-numbers-mode 0)))))

(dolist (mode '(text-mode-hook
                prog-mode-hook
                conf-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 1))))

;; Override some modes which derive from the above
(dolist (mode '(org-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;;removed for symbol searching
;; (add-hook 'prog-mode-hook 'subword-mode)

(use-package evil-nerd-commenter
  :bind ("M-;" . evilnc-comment-or-uncomment-lines))

(use-package minimap)

(setq minimap-window-location 1)

(global-set-key (kbd "C-c s m")  'minimap-mode)

(use-package web-mode)
(setq web-mode-enable-current-column-highlight t)
(setq web-mode-enable-current-element-highlight t)
                                        ; hook into web mode for file types
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.[agj]sp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
;;using rsjx mode
;;(add-to-list 'auto-mode-alist '("\\.js\\'" . web-mode))
                                        ;(add-to-list 'auto-mode-alist '("\\.css?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.xml\\'" . web-mode))
;; using rsjx mode
;;(add-to-list 'auto-mode-alist '("\\.jsx\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.ts\\'" . web-mode))



                                        ; set company completions vocab to css and html

(setq web-mode-enable-engine-detection t)

(use-package emmet-mode
  :bind (
         :map emmet-mode-keymap
         ("H-n" . emmet-next-edit-point)
         ("H-p" . emmet-prev-edit-point)))
                                        ; use emmet in all web-mode docs
(add-hook 'web-mode-hook 'emmet-mode)
(add-hook 'css-mode-hook 'emmet-mode)

                                        ; enable mode switching between css and java
(add-hook 'web-mode-before-auto-complete-hooks
          '(lambda ()
             (let ((web-mode-cur-language
                    (web-mode-language-at-pos)))
               (if (string= web-mode-cur-language "php")
                   (yas-activate-extra-mode 'php-mode)
                 (yas-deactivate-extra-mode 'php-mode))
               (if (string= web-mode-cur-language "css")
                   (setq emmet-use-css-transform t)
                 (setq emmet-use-css-transform nil)))))



; breadcrumb setup

(defun lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deffered)
  :hook (lsp-mode . lsp-mode-setup)
  :init
  (setq lsp-keymap-prefix "C-c l")
  :config
  (lsp-enable-which-key-integration t))
                                        ; turn on lsp ui

(use-package lsp-ui
  :after lsp
  :hook (lsp-mode . lsp-ui-mode)
  :config
  (setq lsp-ui-doc-position 'bottom))

(use-package treemacs
  :config
  (setq treemacs-select-when-already-in-treemacs 'close))


(use-package lsp-treemacs
  :after lsp)
(setq treemacs-select-when-already-in-treemacs 'close)

(use-package typescript-mode
  :mode "\\.ts\\'"
  :hook (typescript-mode . lsp-deferred)
  :config
  (setq typescript-indent-level 2))

(use-package rjsx-mode
  :mode ("\\.js\\'"
         "\\.jsx\\'")
  :config
  (setq js2-mode-show-parse-errors nil
        js2-mode-show-strict-warnings nil
        js2-basic-offset 2
        js-indent-level 2)
  ;; (setq-local flycheck-disabled-checkers (cl-union flycheck-disabled-checkers
  ;;                                                  '(javascript-jshint))) ; jshint doesn't work for JSX
  (show-paren-mode 1)
  (electric-pair-mode 1))

(use-package add-node-modules-path
  :defer t
  :hook (((js2-mode rjsx-mode) . add-node-modules-path)))

;; prettify

(use-package prettier-js
  :defer t
  :diminish prettier-js-mode
  :hook (((js2-mode rjsx-mode) . prettier-js-mode)))

;; setup lsp mode
(use-package lsp-mode
  :defer t
  :diminish lsp-mode
  :hook (((js2-mode rjsx-mode) . lsp))
  :commands lsp
  :config
  (setq lsp-auto-configure t
        lsp-auto-guess-root t
        ;; don't set flymake or lsp-ui so the default linter doesn't get trampled
        lsp-diagnostic-package :none))



(use-package lsp-ui
  :defer t
  :config
  (setq lsp-ui-sideline-enable t
        ;; disable flycheck setup so default linter isn't trampled
        lsp-ui-flycheck-enable nil
        lsp-ui-sideline-show-symbol nil
        lsp-ui-sideline-show-hover nil
        lsp-ui-sideline-show-code-actions nil
        lsp-ui-peek-enable nil
        lsp-ui-imenu-enable nil
        lsp-ui-doc-enable nil))


(defun my-js-comint-keys ()
  "My Keys for sending to the js-comint repl"
  (interactive)
  (local-set-key (kbd "C-x C-e") 'js-send-last-sexp)
  (local-set-key (kbd"C-c b") 'js-send-buffer)
  ;;(local-set-key (kbd"C-c r") 'js-send-region)
  (local-set-key (kbd"C-c C-r") 'js-send-region-and-go))




(require 'js-comint)
(setq inferior-js-program-command "node --interactive")
(setenv "NODE_NO_READLINE" "1")
(add-hook 'rjsx-mode-hook 'my-js-comint-keys)
(add-hook 'rjsx-mode-hook 'emmet-mode)


(with-eval-after-load 'flycheck
  (flycheck-add-next-checker 'javascript-eslint '(t . javascript-jscs)))

;; This isn't really a package, it just provides a `haxe-mode' to work with
(use-package haxe-mode
  :mode ("\\.hx\\'" . haxe-mode)
  :no-require t
  :init
  (require 'js)
  (define-derived-mode haxe-mode js-mode "Haxe"
    "Haxe syntax highlighting mode. This is simply using js-mode for now."))

(use-package battle-haxe
  :hook (haxe-mode . battle-haxe-mode)
  :bind (("S-<f4>" . #'pop-global-mark) ;To get back after visiting a definition
         :map battle-haxe-mode-map
         ("<f5>" . #'battle-haxe-goto-definition)
         ("<f12>" . #'battle-haxe-helm-find-references))
  :custom
  (battle-haxe-yasnippet-completion-expansion t "Keep this if you want yasnippet to expand completions when it's available.")
  (battle-haxe-immediate-completion nil "Toggle this if you want to immediately trigger completion when typing '.' and other relevant prefixes."))

(use-package company
  :after lsp-mode
  :hook ((lsp-mode web-mode) . company-mode)
  :bind (
         :map company-active-map
         ( "<tab>" . company-complete-selection)
         ( "<C-tab>" . company-yasnippet)
         :map lsp-mode-map
         ("<tab>" . company-indent-or-complete-common)))
(setq company-minimum-prefix-length 2)



(use-package company-web
  :after company)


(defun my-web-mode-hook ()
  (set (make-local-variable 'company-backends) '(company-css company-web-html company-yasnippet company-files)))  

(add-hook 'web-mode-hook 'my-web-mode-hook)

(global-set-key (kbd "M-=") 'dabbrev-expand)
(global-set-key (kbd "C-M-=") 'dabbrev-completion)

(defun next-tag()
  (interactive)
  (web-mode-element-next)
  (web-mode-tag-end))



(global-set-key  (kbd "C-x t") 'next-tag)

;; timer controls
(global-set-key (kbd "H-t t") 'org-timer-set-timer)
(global-set-key (kbd "H-t s") 'org-timer-start)
(global-set-key (kbd "H-t x") 'org-timer-stop)
(global-set-key (kbd "H-t z") 'org-timer-pause-or-continue)


;; set ctrl z to undo
(global-set-key (kbd "C-z") 'undo)

;; Macros & commands
                                        ;(fset 'buffer-quick-switch
                                        ;     (kmacro-lambda-form [?\C-x ?b return] 0 "%d"))

(defun buffer-cycle-hidden()
  "cycle through previously hidden buffers"
  (interactive)
  (switch-to-buffer (last-buffer)))

(defun buffer-last()
  "quickly switch to the previous buffer"
  (interactive)
  (switch-to-buffer (other-buffer)))

(defun kill-current-buffer-and-window ()
  "Kill the current buffer then clear the window"
  (interactive)
  (progn
    (kill-current-buffer)
    (delete-window)))


;; Bindings
(global-set-key (kbd "M-+") 'other-window)
(global-set-key (kbd "M-]") 'ace-window)
(global-set-key (kbd "<C-H-tab>") 'treemacs-select-window)
(global-set-key (kbd "M-[") 'treemacs)
(global-set-key (kbd "H-<escape>") 'delete-window)
(global-set-key (kbd "C-H-<escape>") 'delete-frame)
(global-set-key (kbd "H-1") 'delete-other-windows)
(global-set-key (kbd "C-H-M-<escape>") 'delete-other-frames)
(global-set-key (kbd "H-2") 'split-window-below)
(global-set-key (kbd "H-3") 'split-window-right)
(global-set-key (kbd "C-H-b") 'buffer-menu)
(global-set-key (kbd "H-b") 'buffer-last)
(global-set-key (kbd "M-H-b") 'buffer-cycle-hidden)
(global-set-key (kbd "C-H-g") 'list-bookmarks)
(global-set-key (kbd "C-H-t") 'dired-jump)
(global-set-key (kbd "H-k") 'kill-current-buffer)
(global-set-key (kbd "C-H-k") 'kill-current-buffer-and-window)
(global-set-key (kbd "H-+") 'other-frame)
(global-set-key (kbd "C-H-i") 'clone-indirect-buffer-other-window)

;; ascii codes for registers
;; a = 97
;; s = 115
;; d = 100
;; f = 102

(defvar
  active-harpoon)
(setq active-harpoon 102)

(defun current-buffer-is-harpooned (marker)
  (and (eq (marker-buffer marker) (current-buffer))))  

(defun harpoon-f ()
  "Update point if in an a harpooned register and jump to the point harpooned in the 'f' register."
  (interactive)
  (if (current-buffer-is-harpooned (get-register active-harpoon)) (point-to-register active-harpoon))
  (jump-to-register 102)
  (setq active-harpoon 102))

(defun set-harpoon-f ()
  "Harpoon the current buffer in the 'f' register"
  (interactive)
  (point-to-register 102)
  (setq active-harpoon 102)    
  )

(defun harpoon-d ()
  "Update point if in an a harpooned register and jump to the point harpooned in the 'd' register."    
  (interactive)
  (if (current-buffer-is-harpooned (get-register active-harpoon)) (point-to-register active-harpoon))
  (jump-to-register 100)
  (setq active-harpoon 100))

(defun set-harpoon-d ()
  "Harpoon the current buffer in the 'd' register"
  (interactive)
  (point-to-register 100)
  (setq active-harpoon 100)    
  )

(defun harpoon-a ()
  "Update point if in an a harpooned register and jump to the point harpooned in the 'a' register."    
  (interactive)
  (if (current-buffer-is-harpooned (get-register active-harpoon)) (point-to-register active-harpoon))
  (jump-to-register 97)
  (setq active-harpoon 97))

(defun set-harpoon-a ()
  "Harpoon the current buffer in the 'a' register"
  (interactive)
  (point-to-register 97)
  (setq active-harpoon 97)    
  )

(defun harpoon-s ()
  "Update point if in an a harpooned register and jump to the point harpooned in the 'f' register."
  (interactive)
  (if (current-buffer-is-harpooned (get-register active-harpoon)) (point-to-register active-harpoon))
  (jump-to-register 115)
  (setq active-harpoon 115))

(defun set-harpoon-s ()
  "Harpoon the current buffer in the 's' register"    
  (interactive)
  (point-to-register 115)
  (setq active-harpoon 115)
  )

(global-set-key (kbd "H-a") 'harpoon-a)
(global-set-key (kbd "C-H-a") 'set-harpoon-a)
(global-set-key (kbd "H-s") 'harpoon-s)
(global-set-key (kbd "C-H-s") 'set-harpoon-s)
(global-set-key (kbd "H-d") 'harpoon-d)
(global-set-key (kbd "C-H-d") 'set-harpoon-d)
(global-set-key (kbd "H-f") 'harpoon-f)
(global-set-key (kbd "C-H-f") 'set-harpoon-f)

(defun my/pop-local-mark-ring ()
  "Move cursor to last mark position of current buffer, repeat calls will cycle"
  (interactive)
  (set-mark-command t))

(defun my/pop-global-mark-ring()
  "move cursor to last mark in global ring, repeat calls will cycle"
  (interactive)
  (pop-global-mark)
  (set-temporary-overlay-map
   (let ((map (make-sparse-keymap)))
     (define-key map (kbd "m") 'my/pop-global-mark-ring)
     map))
  )


(defun my/insert-line-above-and-go ()
  ;;insert a line above the current one and move the cursor there
  (interactive)
  (previous-line nil)
  (move-end-of-line nil)
  (electric-newline-and-maybe-indent)
  (indent-relative-first-indent-point))


(defun wrap-sexp-backward-with-parenthesis()
  "wrap the current expression backwards with parenthesis"
  (interactive)
  (backward-sexp)
  (mark-sexp) 
  (insert-parentheses))

(global-set-key (kbd "M-o") 'my/insert-line-above-and-go)
;; move C-j to C-; indent-new-comment-line
(global-set-key (kbd "C-;") 'indent-new-comment)                      
(global-set-key (kbd "H-]") 'xref-find-references)
(global-set-key (kbd "H-[") 'xref-go-back)
(global-set-key (kbd "H-g") 'goto-line)
(global-set-key (kbd "C-(") 'wrap-sexp-backward-with-parenthesis)
;; swap point and mark
(global-set-key (kbd "M-m")  (kmacro-lambda-form [?\C-u ?\C-x ?\C-x] 0 "%d"))
;; cycle marks
(global-set-key (kbd "H-m") 'my/pop-local-mark-ring)
(global-set-key (kbd "C-H-m") 'my/pop-global-mark-ring)
;; rebind back-to-indentation to "M-i" NOTE this unbinds!! tab-to-tab-stop
(global-set-key (kbd "M-i") 'back-to-indentation)

(defun duplicate-current-line()
  "Duplicates the entire line under point. Repetable with 'd' "
  (interactive)
  (back-to-indentation)
  (kill-line)
  (yank)
  (newline)
  (indent-for-tab-command)
  (yank)
  (set-temporary-overlay-map
   (let ((map (make-sparse-keymap)))
     (define-key map (kbd "y") 'duplicate-current-line)
     map)))

(defun duplicate-line-up-to-point()
  "Duplicates a line from start of indentation up to point. May be repeated with single 'd' presses."
  (interactive)
  (set-mark-command nil)
  (back-to-indentation)
  (kill-ring-save (region-beginning) (region-end))
  (end-of-line)
  (newline)
  ;; example of single key repeat functionality
  (yank)
  (set-temporary-overlay-map
   (let ((map (make-sparse-keymap)))
     (define-key map (kbd "y") 'duplicate-line-up-to-point)
     map)))

(defun kill-word-at-point()
  "Kill the full word at point"
  (interactive)
  (kill-word 1)
  (backward-kill-word 1))

(defun kill-line-at-point()
  "Kill full lilne at point"
  (interactive)
  (back-to-indentation)
  (kill-line))

(global-set-key (kbd "C-M-i") 'indent-region)
(global-set-key (kbd "M-DEL") 'kill-word-at-point)
(global-set-key (kbd "M-k") 'kill-line-at-point)
(global-set-key (kbd "s-k") 'kill-sentence)
(global-set-key (kbd "s-y") 'duplicate-current-line)
(global-set-key (kbd "H-y") 'duplicate-line-up-to-point)

(global-set-key (kbd "H-w") 'widen)
(global-set-key (kbd "H-e") 'narrow-to-region)
(global-set-key (kbd "H-e") 'narrow-to-defun)
(global-set-key (kbd "C-H-e") 'narrow-to-page)

(let (state)
  (defun my/toggle-org-agenda-restriction ()
    "Toggle agenda restriction"
    (setq state nil)
    (interactive)
    (setq state (not state))
    (if (eq state nil)
        (org-agenda-remove-restriction-lock)
      (my/org-agenda-set-restriction-lock))))

(defun my/org-agenda-set-restriction-lock ()
  "set agenda lock and refresh"
  (interactive)
  (progn 
    (org-agenda-set-restriction-lock-from-agenda ())
    (org-agenda-redo)))

(defun my/next-error()
  "create a repetable next-error command"
  (interactive)
  (next-error)
  (set-temporary-overlay-map
   (let ((map (make-sparse-keymap)))
     (define-key map (kbd "o") 'my/next-error)
     map))
  )

(defun my/org-occur()
  "Run occur and let additional presses of o trigger next-error results"
  (interactive)
  (progn
    (call-interactively 'org-occur)
    (my/next-error)))

(fset 'my/create-morning-startup
      (kmacro-lambda-form [?< ?m ?o ?r ?n ?i ?n ?g tab ?\M-x ?o ?r ?g ?- ?t ?r ?a ?n ?s ?c ?l ?u ?s ?i ?o ?n ?- ?m ?o ?d ?e return ?\M-x return] 0 "%d"))

; list directories first
(setq dired-listing-switches "-agho --group-directories-first")
(setq dired-dwim-target t)

;;  (use-package dired-single)

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

(defun my-dired-mode-hook ()
  "My `dired' mode hook."
  ;; To hide dot-files by default
  (dired-hide-dotfiles-mode))

;; To toggle hiding
(define-key dired-mode-map "." #'dired-hide-dotfiles-mode)
(add-hook 'dired-mode-hook #'my-dired-mode-hook)

;;set load path for person elisp

;; Removing iy-go-to-char
                                        ;load the package iy-go-to-char
                                        ;(load "iy-go-to-char")


(global-set-key (kbd "<f6>") 'browse-url-of-buffer)

;;Calendar keys
(global-set-key (kbd "s-c") 'calendar)

;; open
(fset 'my/org-insert-clean-link
      (kmacro-lambda-form [?\[ ?\[ ?\C-d ?\C-y ?\C-f ?\[ ?l ?i ?n ?k ?\C-e ?\]] 0 "%d"))

(global-set-key (kbd "s-l") 'my/org-insert-clean-link)
(global-set-key (kbd "C-M-.") 'counsel-git-grep)


;;indenting commands
(global-set-key (kbd "C-c i c") 'indent-to-column)

(global-set-key (kbd "M-SPC") 'cycle-spacing)   

;; macros to set agenda categories
(fset 'my/org-agenda-set-category-project
      (kmacro-lambda-form [?\C-c ?\C-x ?p ?C ?A ?T ?E ?G ?O ?R ?Y return ?P ?r ?o ?j ?e ?c ?t return ?r] 0 "%d"))
(fset 'my/org-agenda-set-category-task
      (kmacro-lambda-form [?\C-c ?\C-x ?p ?C ?A ?T ?E ?G ?O ?R ?Y return ?T ?a ?s ?k return ?r] 0 "%d"))

(when (member "Segoe UI Emoji" (font-family-list))
  (set-fontset-font
   t 'symbol (font-spec :family "Segoe UI Emoji") nil 'prepend))


(setq emojify-display-style 'unicode)
(setq emojify-emoji-styles '(unicode))



(use-package emojify
  :config
  (when (member "Segoe UI Emoji" (font-family-list))
    (set-fontset-font
     t 'symbol (font-spec :family "Segoe UI Emoji") nil 'prepend))
  (setq emojify-display-style 'unicode)
  (setq emojify-emoji-styles '(unicode))
  (bind-key* (kbd "C-c .") #'emojify-insert-emoji)) ; override binding in any mode

(require 'org-bookmark-heading)

(defun play-retro-sax ()
  "Launch a retro sax 3 hour video"
  (interactive)
  (browse-url "https://www.youtube.com/watch?v=001hXHNo-3w"))

(defun play-high-bpm-trance ()
  "Launch high bpm trance video"
  (interactive)
  (browse-url "https://youtu.be/q7gv9B4Kw44"))


(defhydra Music (global-map "<f7>")
  "Music Player"
  ("s" play-retro-sax "Retro-Sax")
  ("h" play-high-bpm-trance "High BPM Trance"))

(fset 'my/dired-create-game-design-structure
      (kmacro-lambda-form [?\M-x ?m ?k ?d ?i ?r return ?d ?e ?s ?i ?g ?n return ?\M-x ?m ?d ?k backspace backspace ?k ?d ?i ?r return ?d ?e ?v ?e ?l ?o ?p ?m ?e ?n ?t return ?\M-x ?m ?k ?d ?i ?r return ?d ?o ?c ?u ?m ?e ?n ?t ?a ?t ?i ?o ?n return ?\M-x ?m ?k ?d ?i ?r return ?i ?m ?a ?g ?e ?s return ?\M-x ?m ?k ?d ?i ?r ?  ?p ?l ?a ?y ?t ?e ?s ?t ?s return backspace backspace backspace backspace backspace backspace backspace backspace backspace backspace return ?p ?l ?a ?y ?t ?e ?s ?t ?s return] 0 "%d"))

(fset 'my/dired-populate-design-docs
      (kmacro-lambda-form [?\C-x ?\C-f ?R ?E ?A ?D ?M ?E ?. ?o ?r ?g return ?\C-x ?\C-s ?\H-k ?g ?\C-x ?\C-f ?d ?e ?s ?i ?g ?n ?/ ?D ?e ?s ?i ?g ?n ?- ?L ?o ?g ?. ?o ?r ?g return ?\C-x ?\C-s ?\H-k ?\C-x ?\C-f ?d tab ?D ?e ?s ?i ?g backspace backspace backspace backspace backspace ?M ?a ?s ?t ?e ?r ?- ?D ?e ?s ?i ?g ?n ?- ?D ?o ?c ?. ?o ?r ?g return ?\C-x ?\C-s ?\H-k ?\C-x ?\C-f ?p ?l ?a ?y tab ?P ?l ?a ?y ?t ?e ?s ?t ?s ?. ?o ?r ?g return ?\C-x ?\C-s ?\H-k ?\C-s ?\C-f ?\C-x ?\C-f ?d ?o ?c ?u tab ?R ?u ?l ?e ?s ?. ?o ?r ?g return ?\C-x ?\C-s ?\H-k] 0 "%d"))

(fset 'my/create-new-design
      (kmacro-lambda-form [?\M-x ?m ?y ?/ return ?g ?\M-x ?m ?y ?/ ?\C-n ?\C-n ?\C-n ?\C-n return ?g] 0 "%d"))

(defun xah-beginning-of-line-or-block ()
  "Move cursor to beginning of line or previous block.

• When called first time, move cursor to beginning of char in current line. (if already, move to beginning of line.)
• When called again, move cursor backward by jumping over any sequence of whitespaces containing 2 blank lines.
• if `visual-line-mode' is on, beginning of line means visual line.

URL `http://xahlee.info/emacs/emacs/emacs_keybinding_design_beginning-of-line-or-block.html'
Version: 2018-06-04 2021-03-16 2022-03-30 2022-07-03 2022-07-06"
  (interactive)
  (let (($p (point)))
    (if (or (equal (point) (line-beginning-position))
            (eq last-command this-command))
        (when
            (re-search-backward "\n[\t\n ]*\n+" nil 1)
          (skip-chars-backward "\n\t ")
          (forward-char))
      (if visual-line-mode
          (beginning-of-visual-line)
        (if (eq major-mode 'eshell-mode)
            (progn
              (declare-function eshell-bol "esh-mode.el" ())
              (eshell-bol))
          (back-to-indentation)
          (when (eq $p (point))
            (beginning-of-line)))))))


(defun xah-end-of-line-or-block ()
  "Move cursor to end of line or next block.

• When called first time, move cursor to end of line.
• When called again, move cursor forward by jumping over any sequence of whitespaces containing 2 blank lines.
• if `visual-line-mode' is on, end of line means visual line.
URL `http://xahlee.info/emacs/emacs/emacs_keybinding_design_beginning-of-line-or-block.html'
Version: 2018-06-04 2021-03-16 2022-03-05"
  (interactive)
  (if (or (equal (point) (line-end-position))
          (eq last-command this-command))
      (re-search-forward "\n[\t\n ]*\n+" nil 1)
    (if visual-line-mode
        (end-of-visual-line)
      (end-of-line))))

(global-set-key (kbd "M-p") 'xah-beginning-of-line-or-block)
(global-set-key (kbd "M-n") 'xah-end-of-line-or-block)

;;Make org links open in same window
(setq org-link-frame-setup
      '(
        (vm . vm-visit-folder-other-frame)
        (vm-imap . vm-visit-imap-folder-other-frame)
        (gnus . org-gnus-no-new-news)
        (file . find-file)
        (wl . wl-other-frame)))

;; set org agenda mode map commands 
(define-key org-agenda-mode-map (kbd "H-,") 'org-agenda-remove-restriction-lock)
(define-key org-agenda-mode-map (kbd "H-.") 'org-agenda-set-restriction-lock-from-agenda)
(define-key org-agenda-mode-map (kbd "M-s o") 'org-occur-in-agenda-files)
(define-key org-agenda-mode-map (kbd "[") 'my/org-agenda-set-category-project)
(define-key org-agenda-mode-map (kbd "]") 'my/org-agenda-set-category-task)

(setq default-frame-alist '(
                            (vertical-scroll-bars) 
                            (left-fringe . 10)
                            (right-fringe . 10)
                            (fullscreen . maximized)))
