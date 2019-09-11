(princ "entered emacs-init.el")
;; load arc.el and auto run arc-mode when file is of .arc extension 
(load-file "~/.emacs.d/arc.el") 
(add-to-list 'load-path "~/.emacs.d/extensions_fom_git/autopair")
(add-to-list 'load-path "~/.emacs.d/extensions_fom_git/malabar-mode")
(add-to-list 'load-path "~/.emacs.d/user-plugins/")
(add-to-list 'load-path "/usr/share/emacs/site-lisp")
(add-to-list 'auto-mode-alist '("\\.jsx$" . web-mode))
(add-to-list 'auto-mode-alist '("\\.arc$" . arc-mode))

(autoload 'merlin-mode "merlin" nil t nil)
(add-hook 'tuareg-mode-hook 'merlin-mode t)
(add-hook 'merlin-mode-hook (lambda ()
                              (define-key merlin-mode-map (kbd "RET") (lambda ()
                                                                      (interactive)
                                                                      (merlin-error-check)
                                                                      (insert "\n")))))

(add-hook 'python-mode-hook (lambda ()
                              (define-key python-mode-map (kbd "C-x C-e") 'python-shell-send-region)))

;; requirements.el
;; require everything needed for my customizations
(mapc 'require
      '(git
	autopair
	irony
	tern-auto-complete
	flycheck
	simple-httpd
;;	slime
;;	slime-company
;;	slime-autoloads
	swap
	delete
	insert-date
	arc-company
	tmp-bookmark))
(princ "require done")
;; macro.el
(defmacro => (&rest function-body)
  "Shortcut for a lambda with one argument (the argument name is '_')"
  (cons 'lambda (cons '(_) function-body)))

(defmacro =>> (&rest function-body)
  "Shortcut for a lambda with no arguments"
  (cons 'lambda (cons nil function-body)))
;; function.el
;; global function definitions

;; (defun dabbrev-complation-at-point ()
;;   (dabbrev--reset-global-variables)
;;   (let* ((abbrev (dabbrev--abbrev-at-point))
;;          (candidates (dabbrev--find-all-expansions abbrev t))
;;          (bnd (bounds-of-thing-at-point 'symbol)))
;;     (list (car bnd) (cdr bnd) candidates)))
;; command.el
;; define own commands  

(defun my-delete-compilation-window ()
  (interactive)
  (kill-buffer "*compilation*")
  (delete-other-windows))

(defun my-skewer-eval ()
  (interactive)
  (skewer-eval (buffer-substring-no-properties (mark) (point))))

(defun smart-beginning-of-line ()
  "Move point to first non-whitespace character or beginning-of-line.

Move point to the first non-whitespace character on this line.
If point was already at that position, move point to beginning of line."
  (interactive "^") ; Use (interactive) in Emacs 22 or older
  (let ((oldpos (point)))
    (back-to-indentation)
    (and (= oldpos (point))
         (beginning-of-line))))

(defun sudo-find-file (&optional file-name)
  (interactive "")
  (find-file (concat "/sudo::" (or file-name
                                   (buffer-file-name)))))
;; key-bindings.el
;; define everything needed for ../key-bindings.el to run

;; macro definitions
(defmacro global-set-keys (&rest keys&symbols)
  "Sets multiple keys, syntax example: (global-set-keys (kbd \"<key-sequence>\") function-name [home] function-name ...).
  The function-name is quoted automatically."
  (when (= (logand (length keys&symbols) 1) 1)
    (error "global-set-keys: Given key symbol pairs are not balanced"))
  (let* ((eat-next-key&symbol (lambda (keys&symbols)
				    (when keys&symbols
				      (cons `(global-set-key ,(car keys&symbols) (quote ,(cadr keys&symbols)))
					    (funcall eat-next-key&symbol (cddr keys&symbols)))))))
    (cons 'progn (funcall eat-next-key&symbol keys&symbols))))

;;function definitions
;; (defun my-quit-emacs-and-close-slime-when-needed ()
;;   "Checks if slime is still running and quits it. Then quit emacs"
;;   (interactive)
;;   (when (slime-connected-p)
;;     (slime-quit-lisp)
;;     (sleep-for 0.2))
;;   (save-buffers-kill-terminal))

(defun duplicate-current-line ()
  "copies the current line (not to the kill ring). keeps the mouse position +one line)"
  (interactive)
  (let ((starting-point (point))
	(start (progn (beginning-of-line) (point)))
	(end (progn (end-of-line) (point))))
    (terpri 'insert)
    (insert (buffer-substring start end))
    (goto-char starting-point)
    (next-line)))

(defun my-insert-tab-char ()
  "Use the real tab char and not spaces.
   Insert a tab char. (ASCII 9, \t)"
  (interactive)
  (insert "\t"))
;; hook.el
;; define everything needed for ../hooks.el to run

;; macro definitions
(defmacro add-hooks (&rest keys&symbols)
  "Sets multiple hooks, syntax example: (add-hooks foo-mode-hook function-name  bar-mode-hook function-name ...).
  The function-name and xyz-mode-hook is NOT quoted automatically."
  (when (= (logand (length keys&symbols) 1) 1)
    (error "add-hooks: Given key symbol pairs are not balanced"))
  (let* ((eat-next-key&symbol (lambda (keys&symbols)
				    (when keys&symbols
				      (cons `(add-hook (quote ,(car keys&symbols)) ,(cadr keys&symbols))
					    (funcall eat-next-key&symbol (cddr keys&symbols)))))))
    (cons 'progn (funcall eat-next-key&symbol keys&symbols))))

;;function definitions
(defun my-c-set-offset-to-0 ()
  "sets the c-set-offset to 0 for opening braces"
  (map-apply 'c-set-offset
	     '((substatement-open . 0)
	       (inline-open 0)
	       (block-open 0))))

(defun my-irony-mode-hook ()
 (define-key irony-mode-map [remap completion-at-point]
   'irony-completion-at-point-async)
 (define-key irony-mode-map [remap complete-symbol]
   'irony-completion-at-point-async))
;; set-variables.el
;; set and/or define all variables for my customizations

(defvar tmp-bookmark-markers nil
  "Global variable that holds all markers added from the function add-tmp-bookmark-at-point")

(setq c-default-style "linux"
      c-basic-offset 4
      autopair-autowrap t
      make-backup-files nil
      auto-save-default nil
      inhibit-startup-echo-area-message (user-login-name)
      inhibit-startup-message t
      scroll-preserve-screen-position t
      initial-scratch-message ";; ¡Bienvenido, Hoy es un buen dia!"
      initial-major-mode 'emacs-lisp-mode
      company-idle-delay 0
      ring-bell-function 'ignore;;stop the annoying BEEPS when for eg. you are at the beginning/end of a file
      httpd-port 4321
      httpd-root "/home/lukas/Programming/html/skewer"
      ;; inferior-lisp-program "~/Downloads/extracted/clisp-2.49/src/clisp -I"
      inferior-lisp-program "/usr/lib/ccl/lx86cl64"
      pop-up-windows nil
      show-paren-delay 0
      js2-highlight-level 3 
      enable-local-variables nil);; prevents emacs to automatically execute so called 'local variable lists' that are normally executed when opening a file where they are defined at the bottom of the file

(setq-default c-basic-offset 4
	      tab-width 4
	      indent-tabs-mode nil
	      truncate-lines t
          indent-line-function 'insert-tab)

;;(setq inferior-lisp-program "/usr/bin/clisp")
;;(setq inferior-lisp-program "/home/lukas/Downloads/extracted/clisp-2.49/src/lisp.run -M /home/lukas/Downloads/extracted/clisp-2.49/src/lispinit.mem")
;;(setq inferior-lisp-program "/usr/lib/ccl/lx86cl64")
;;(setq inferior-lisp-program "/usr/bin/arc")
;;(add-to-list 'load-path "/usr/share/emacs/site-lisp/slime/")
;; key-bindings.el
;; bind all my keys to the right place

(global-set-keys
 (kbd "<f6>")    iedit-mode
 (kbd "C-h")     delete-word-backward
 [(C delete)]    delete-word
 (kbd "C-k")     delete-line
 (kbd "C-x x")   compile
 (kbd "C-x c")   my-delete-compilation-window
 [home]          smart-beginning-of-line
 (kbd "C-c C-d") ace-jump-mode
 (kbd "C-d")     duplicate-current-line
 ;; (kbd "C-x C-c")  my-quit-emacs-and-close-slime-when-needed
 ;; (kbd "TAB")     my-insert-tab-char
 [(M up)]        swap-lines-up
 [(M down)]      swap-lines-down
 [(M left)]      pop-tmp-bookmark
 (kbd "M-#")     add-tmp-bookmark-at-point
 ;;(kbd "C-s") swiper
 (kbd "C-s") isearch-forward
 )
(princ "global key set done")
;; (mapc 'global-set-key
;;       (list (kbd "<f6>") (kbd "C-h")             (kbd "C-k")    (kbd "C-x x") (kbd "C-x c")                [home]                   (kbd "C-c C-d") (kbd "C-d")            (kbd "C-x C-c")                            [(M up)]      [(M down)])
;;       '(    iedit-mode   my-backward-delete-word my-delete-line compile       my-delete-compilation-window smart-beginning-of-line ace-jump-mode    duplicate-current-line my-quit-emacs-and-close-slime-when-needed) swap-lines-up swap-lines-down)
;; hooks.el
;; add all needed hooks

(add-hooks
 ;;slime-mode-hook (=>> (define-key slime-mode-map (kbd "C-c C-t") 'slime-edit-local-definition))
 irony-mode-hook 'my-irony-mode-hook
 irony-mode-hook 'my-irony-mode-hook
 irony-mode-hook 'irony-cdb-autosetup-compile-options
 java-mode-hook  'my-c-set-offset-to-0
 c++-mode-hook   (=>> (my-c-set-offset-to-0) (define-key c++-mode-map (kbd "C-d") 'duplicate-current-line))
 js-mode-hook    'js2-minor-mode
 js2-mode-hook   (=>> (auto-complete-mode t))
 js2-mode-hook   'ac-js2-mode
 js-mode-hook    (=>> (tern-mode t))
 web-mode-hook   (=>> (tern-mode t))
 arc-mode-hook   (=>> (define-key arc-mode-map (kbd "C-x C-e") 'scheme-send-last-sexp))
 org-mode-hook   (=>> (define-key org-mode-map (kbd "C-.") 'org-indent-line))
 c-mode-hook     (=>> (define-key c-mode-map (kbd "C-d") 'duplicate-current-line) ;;(company-mode -1) (auto-complete-mode)
                      )
 web-mode-hook   (=>> (flycheck-select-checker 'jsxhint-checker) (flycheck-mode)))
;; init.el
(autopair-global-mode 1)
(global-company-mode)
(define-arc-symbols)
(ivy-mode 1)
;; (add-to-list 'load-path "/home/lukas/.emacs.d/elpa/slime-20171106.1331/contrib")
;; (slime-setup '(slime-xref-browser
;;                slime-autodoc
;;                slime-asdf
;;                slime-scratch
;;                slime-mdot-fu
;;                slime-asdf
;;                slime-banner
;;                slime-company
;;                slime-repl
;;                slime-fuzzy
;;                inferior-slime))
;; (slime)
;; (switch-to-prev-buffer)
;;show matching parenthesis
(show-paren-mode)
(menu-bar-mode -1)
(smooth-scrolling-mode)
;; Set the encoding of the files to utf-8
(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)

(eval-after-load 'tern
   '(progn
      (require 'tern-auto-complete)
      (tern-ac-setup)))

;; This makes slime fancy but destroys the autocompletion...
;;(eval-after-load "slime"
  ;;'(progn
    ;; (add-to-list 'load-path "/usr/local/slime/contrib")
    ;; (slime-setup '(slime-fancy slime-banner))
    ;; (setq slime-complete-symbol*-fancy t)
    ;; (setq slime-complete-symbol-function 'slime-fuzzy-complete-symbol)))

(add-to-list 'company-backends 'arc-company-backend)

;;add autocompletion for ivy, activate with C-M-/
;; (add-to-list 'completion-at-point-functions 'dabbrev-complation-at-point) ;; <-- the function is broken

;; highlight current line
;; (global-hl-line-mode 1)
;; (set-face-background 'highlight "#222222")
;; (set-face-foreground 'highlight nil)
;; (set-face-underline-p 'highlight nil)

;; setup flycheck with jsx
(flycheck-define-checker jsxhint-checker
  "A JSX syntax and style checker based on JSXHint."

  :command ("jsxhint" source)
  :error-patterns
  ((error line-start (1+ nonl) ": line " line ", col " column ", " (message) line-end))
  :modes (web-mode))

(defun yyo (a)
             (when (looking-back "lambda" 6)
               (let ((rest-of-lambda (match-string 0)))
                 (delete-char -6)
                 (insert 955))))

;; (advice-add 'self-insert-command :after 'yyo)

;; custom mode-line
(defun my-update-mode-line ()
  (let ((colorize
         (lambda (str)
           (cl-reduce (lambda (str char)
                        (concat str (if (cl-find char ".:*")
                                        (propertize (char-to-string char) 'face '(:foreground "#eb0e69"))
                                      (char-to-string char))))
                      str
                      :initial-value ""))))
    (setq-default
     mode-line-format
     `(" "
       (:eval (if (and buffer-file-name (buffer-modified-p)) (propertize "*" 'face '(:foreground "#eb0e69")) ""))
       " "
       (:eval (,colorize (buffer-name)))
       " %lL"
       (:eval (if buffer-read-only " READ ONLY" ""))
       "   "
       (:eval (,colorize (format-time-string "%H:%M %d.%m.%Y")))))))

(fringe-mode 0)
(setq-default cursor-type 'bar)
(setq-default line-spacing 4)
(my-update-mode-line)

(defvar line-padding 2)
(defun add-line-padding ()
  "Add extra padding between lines"

  ; remove padding overlays if they already exist
  (let ((overlays (overlays-at (point-min))))
    (while overlays
      (let ((overlay (car overlays)))
        (if (overlay-get overlay 'is-padding-overlay)
            (delete-overlay overlay)))
      (setq overlays (cdr overlays))))

  ; add a new padding overlay
  (let ((padding-overlay (make-overlay (point-min) (point-max))))
    (overlay-put padding-overlay 'is-padding-overlay t)
    (overlay-put padding-overlay 'line-spacing (* .1 line-padding))
    (overlay-put padding-overlay 'line-height (+ 1 (* .1 line-padding))))
  (setq mark-active nil))
;; (add-hook 'buffer-list-update-hook 'add-line-padding)


