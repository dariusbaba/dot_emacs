;;; anything-bundle.el --- Just anything

;;; Commentary:
;;

;;; Code:

(setq make-backup-files nil)
(menu-bar-mode -1)

;; (setq x-select-enable-clipboard t)
;; (setq interprogram-paste-function 'x-cut-buffer-or-selection-value)

(smex-initialize)
;(ido-hacks 1)

(projectile-mode t)

;; Show projectile lists by most recently active
(setq projectile-sort-order (quote recently-active))

(setq ido-decorations (quote ("\n↪ "     "" "\n   " "\n   ..." "[" "]" " [No match]" " [Matched]" " [Not readable]" " [Too big]" " [Confirm]")))


(require 'flx-ido)
(ido-mode 1)
(ido-everywhere 1)
(flx-ido-mode 1)


;; Parens handling
;; Show and create matching parens automatically
(show-paren-mode t)
(smartparens-global-mode t)
(show-smartparens-global-mode nil)
(setq sp-autoescape-string-quote nil)
;; Do not highlight paren area
(setq sp-highlight-pair-overlay nil)
(setq sp-highlight-wrap-overlay nil)
(setq sp-highlight-wrap-tag-overlay nil)
;; Do not use default slight delay
(setq show-paren-delay 0)

;;==============================================================================
;; Autocomplete with company-mode
;;==============================================================================
(global-company-mode t)
(setq company-tooltip-limit 12)                      ; bigger popup window
(setq company-idle-delay .1)                         ; decrease delay before autocompletion popup shows
(setq company-echo-delay 0)                          ; remove annoying blinking
(setq company-begin-commands '(self-insert-command)) ; start autocompletion only after typing
(setq company-dabbrev-downcase nil)                  ; Do not convert to lowercase
(setq company-selection-wrap-around t)               ; continue from top when reaching bottom

;; Hack to trigger candidate list on first TAB, then cycle through candiates with TAB
(defvar tip-showing nil)
(eval-after-load 'company
  '(progn
     (define-key company-active-map (kbd "TAB")  (lambda ()
       (interactive)
       (company-complete-common)
       (if tip-showing
         (company-select-next))
     ))
     (define-key company-active-map [tab] 'company-select-next)))

(defun company-pseudo-tooltip-on-explicit-action (command)
  "`company-pseudo-tooltip-frontend', but only on an explicit action."
  (when (company-explicit-action-p)
    (setq tip-showing t)
    (company-pseudo-tooltip-frontend command)))

(defun company-echo-metadata-on-explicit-action-frontend (command)
  "`company-mode' front-end showing the documentation in the echo area."
  (pcase command
    (`post-command (when (company-explicit-action-p)
                     (company-echo-show-when-idle 'company-fetch-metadata)))
    (`hide
      (company-echo-hide)
      (setq tip-showing nil)
     )))

(setq company-frontends '(company-pseudo-tooltip-on-explicit-action company-echo-metadata-on-explicit-action-frontend company-preview-if-just-one-frontend))
;; End TAB cycle hack

(defadvice save-buffer (before save-buffer-always activate)
  "always save buffer"
  (set-buffer-modified-p t))


;; =============================================================================
;; Evil
;; =============================================================================
;; Org mode tab working
(setq evil-want-C-i-jump nil)

(require 'evil)
(evil-mode 1)
(global-evil-visualstar-mode 1)
; (setq evil-default-cursor t)
(progn (setq evil-default-state 'normal)
       (setq evil-auto-indent t)
       (setq evil-shift-width 2)
       (setq evil-search-wrap t)
       (setq evil-find-skip-newlines t)
       (setq evil-move-cursor-back nil)
       (setq evil-mode-line-format 'before)
       (setq evil-esc-delay 0.001)
       (setq evil-cross-lines t))

(setq evil-overriding-maps nil)
(setq evil-intercept-maps nil)

;; Don't wait for any other keys after escape is pressed.
(setq evil-esc-delay 0)

;; Don't show default text in command bar
;  ** Currently breaks visual range selection, looking for workaround
;(add-hook 'minibuffer-setup-hook (lambda () (evil-ex-remove-default)))

;; Make HJKL keys work in special buffers
(evil-add-hjkl-bindings magit-branch-manager-mode-map 'emacs
  "K" 'magit-discard-item
  "L" 'magit-key-mode-popup-logging)
(evil-add-hjkl-bindings magit-status-mode-map 'emacs
  "K" 'magit-discard-item
  "l" 'magit-key-mode-popup-logging
  "h" 'magit-toggle-diff-refine-hunk)
(evil-add-hjkl-bindings magit-log-mode-map 'emacs)
(evil-add-hjkl-bindings magit-commit-mode-map 'emacs)
(evil-add-hjkl-bindings occur-mode 'emacs)
(setq evil-want-C-u-scroll t)

(global-evil-leader-mode)
(evil-leader/set-leader ",")
(evil-leader/set-key
  "." 'find-tag
  "t" 'projectile-find-file
  "b" 'ido-switch-buffer
  "cc" 'evilnc-comment-or-uncomment-lines
  "ag" 'projectile-ag
  "," 'switch-to-previous-buffer
  "gb" 'mo-git-blame-current
  "gL" 'magit-log
  "gs" 'magit-status
  "w"  'kill-buffer
  "nn" 'neotree-toggle
  "nf" 'neotree-find
  "new" 'neotree-create-node'
  "ni" 'neotree-hidden-file-toggle
  "gk" 'windmove-up
  "gj" 'windmove-down
  "gl" 'windmove-right
  "gh" 'windmove-left
  "vs" 'split-window-right
  "hs" 'split-window-below
  "s" 'save-some-buffers
  "x" 'smex)

;; =============================================================================
;; Evil Packages
;; =============================================================================

(require 'evil-surround)
(global-evil-surround-mode 1)

(require 'evil-visualstar)

(defun fix-underscore-word ()
  (modify-syntax-entry ?_ "w"))

(defun buffer-exists (bufname)   (not (eq nil (get-buffer bufname))))
(defun switch-to-previous-buffer ()
  "Switch to previously open buffer.
Repeated invocations toggle between the two most recently open buffers."
  (interactive)
  ;; Don't switch back to the ibuffer!!!
  (if (buffer-exists "*Ibuffer*")  (kill-buffer "*Ibuffer*"))
  (switch-to-buffer (other-buffer (current-buffer) 1)))

;; =============================================================================
;; Evil Bindings
;; =============================================================================
;; (define-key evil-normal-state-map (kbd "RET") 'save-buffer)
(define-key evil-normal-state-map (kbd "C-j") 'evil-scroll-down)
(define-key evil-normal-state-map (kbd "C-k") 'evil-scroll-up)


;; Make ";" behave like ":" in normal mode
(define-key evil-normal-state-map (kbd ";") 'evil-ex)
(define-key evil-visual-state-map (kbd ";") 'evil-ex)
(define-key evil-motion-state-map (kbd ";") 'evil-ex)

;; Yank whole buffer
(define-key evil-normal-state-map (kbd "gy") (kbd "gg v G y"))

(setq key-chord-two-keys-delay 0.075)
(key-chord-mode 1)
(key-chord-define evil-insert-state-map "jk" 'evil-normal-state)
(key-chord-define evil-insert-state-map "JK" 'evil-normal-state)
(key-chord-define evil-insert-state-map "Jk" 'evil-normal-state)

(define-key evil-insert-state-map "j" #'cofi/maybe-exit-j)
(define-key evil-insert-state-map "J" #'cofi/maybe-exit-J)
(evil-define-command cofi/maybe-exit-j ()
  :repeat change
  (interactive)
  (let ((modified (buffer-modified-p)))
    (insert "j")
    (let ((evt (read-event (format "" ?k)
               nil 0.5)))
      (cond
       ((null evt) (message ""))
       ((and (integerp evt) (char-equal evt ?k))
         (delete-char -1)
         (set-buffer-modified-p modified)
         (push 'escape unread-command-events))
       (t (setq unread-command-events (append unread-command-events
                          (list evt))))))))

(evil-define-command cofi/maybe-exit-J ()
  :repeat change
  (interactive)
  (let ((modified (buffer-modified-p)))
    (insert "J")
    (let ((evt (read-event (format "" ?k)
               nil 0.5)))
      (cond
       ((null evt) (message ""))
       ((and (integerp evt) (char-equal evt ?k))
         (delete-char -1)
         (set-buffer-modified-p modified)
         (push 'escape unread-command-events))
       (t (setq unread-command-events (append unread-command-events
                          (list evt))))))))

(define-key evil-normal-state-map "gh" 'windmove-left)
(define-key evil-normal-state-map "gj" 'windmove-down)
(define-key evil-normal-state-map "gk" 'windmove-up)
(define-key evil-normal-state-map "gl" 'windmove-right)

(add-hook 'neotree-mode-hook
 (lambda ()
   (define-key evil-normal-state-local-map (kbd "TAB") 'neotree-enter)
   (define-key evil-normal-state-local-map (kbd "SPC") 'neotree-enter)
   (define-key evil-normal-state-local-map (kbd "q") 'neotree-hide)
   (define-key evil-normal-state-local-map (kbd "RET") 'neotree-enter)
         (define-key evil-normal-state-local-map (kbd "ma") 'neotree-create-node)
         (define-key evil-normal-state-local-map (kbd "md") 'neotree-delete-node)
         (define-key evil-normal-state-local-map (kbd "r") 'neotree-refresh)
         (define-key evil-normal-state-local-map (kbd "mm") 'neotree-rename-node)
))

;; Map ctrl-j/k to up down in ido selections
(add-hook 'ido-setup-hook
  (lambda ()
    (define-key ido-completion-map (kbd "C-j") 'ido-next-match)
    (define-key ido-completion-map (kbd "C-k") 'ido-prev-match)
))


;; =============================================================================
;; UI
;; =============================================================================

(global-linum-mode t)
(setq-default truncate-lines t)

(defun linum-format-func (line)
  (let ((w (length (number-to-string (count-lines (point-min) (point-max))))))
     (propertize (format (format "%%%dd " w) line) 'face 'linum)))

(setq linum-format 'linum-format-func)
;; use customized linum-format: add a addition space after the line number

;; Remember the cursor position of files when reopening them
(setq save-place-file "~/.emacs.d/saveplace")
(setq-default save-place t)
(require 'saveplace)

;; show the column number in the status bar
(column-number-mode t)

;; Powerline
(require 'powerline)
(powerline-vim-theme)

;; Highlight cursor line
(global-hl-line-mode t)
(set-face-background hl-line-face "gray10")

;; Make lines longer than 80 highlighted
(setq whitespace-line-column 120) ;; limit line length
(setq whitespace-style '(face lines-tail))
(global-whitespace-mode t)

(add-hook 'prog-mode-hook 'whitespace-mode)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(require 'smooth-scrolling)
(setq smooth-scroll-margin 3)
;; Delay updates to give Emacs a chance for other changes
(setq linum-delay t)
(setq redisplay-dont-pause t)

; Auto-indent with the Return key
(define-key global-map (kbd "RET") 'newline-and-indent)

(setq inhibit-startup-screen t)

;; =============================================================================
;; Custom Packages
;; =============================================================================

;; (load-theme 'atom-dark)
;; (load-theme 'tsdh-dark)
;; (load-theme 'tango-dark)
;; (load-theme 'junio)

(load-theme 'molokai)

(require 'pbcopy)
(turn-on-pbcopy)

(add-to-list 'load-path "~/.emacs.d/vendor/longlines/")
(require 'longlines)

(require 'elixir-mode)
(add-to-list 'load-path "~/.emacs.d/vendor/alchemist.el")
(require 'alchemist)

(load "~/.emacs.d/vendor/change-case.el")

;; I want underscores as part of word in all modes
(modify-syntax-entry (string-to-char "_") "w" (standard-syntax-table))
(modify-syntax-entry (string-to-char "_") "w" text-mode-syntax-table)
(modify-syntax-entry (string-to-char "_") "w" lisp-mode-syntax-table)
(modify-syntax-entry (string-to-char "_") "w" emacs-lisp-mode-syntax-table)
;; (require 'enh-ruby-mode)

;; flycheck
(add-hook 'after-init-hook #'global-flycheck-mode)

(global-flycheck-mode t)

(modify-syntax-entry (string-to-char "_") "w" elixir-mode-syntax-table)

;; JSX
(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.js?\\'" . web-mode))

;; disable jshint since we prefer eslint checking
(setq-default flycheck-disabled-checkers
  (append flycheck-disabled-checkers '(javascript-jshint)))

;; use eslint with web-mode for jsx files
(flycheck-add-mode 'javascript-eslint 'web-mode)

;; File handling
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Space indentation - I want tab as two spaces everywhere
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)

(add-hook 'elixir-mode-hook (lambda ()
                            (setq evil-shift-width 2)
                            (setq tab-width 2)))

(add-hook 'haml-mode-hook (lambda ()
                            (setq evil-shift-width 2)
                            (setq tab-width 2)))

(add-hook 'html-mode-hook (lambda ()
                            (setq evil-shift-width 2)
                            (setq tab-width 2)))

;; adjust indents for web-mode to 2 spaces
(defun my-web-mode-hook ()
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2))
(add-hook 'web-mode-hook  'my-web-mode-hook)

;; Play nice with evil-mode in compilation-mode, ie project-ag results
(add-hook 'compilation-mode-hook '(lambda ()
                                    (local-unset-key "g")
                                    (local-unset-key "h")
                                    (local-unset-key "k")))

;; Enable syntax highlighting in markdown
(require 'mmm-mode)
    (mmm-add-classes
    '((markdown-elixirp
      :submode elixir-mode
      :face mmm-declaration-submode-face
      :front "^\{:language=\"elixir\"\}[\n\r]+~~~"
      :back "^~~~$")))

  (mmm-add-classes
    '((markdown-jsp
      :submode js-mode
      :face mmm-declaration-submode-face
      :front "^\{:language=\"javascript\"\}[\n\r]+~~~"
      :back "^~~~$")))

    (mmm-add-classes
    '((markdown-elixir
      :submode elixir-mode
      :face mmm-declaration-submode-face
      :front "^~~~\s?elixir[\n\r]"
      :back "^~~~$")))

  (mmm-add-classes
    '((markdown-js
      :submode js-mode
      :face mmm-declaration-submode-face
      :front "^~~~\s?javascript[\n\r]"
      :back "^~~~$")))


;; (setq mmm-global-mode 't)
(setq mmm-submode-decoration-level 0)

(add-to-list 'mmm-mode-ext-classes-alist '(markdown-mode nil markdown-elixirp))
(add-to-list 'mmm-mode-ext-classes-alist '(markdown-mode nil markdown-jsp))
(add-to-list 'mmm-mode-ext-classes-alist '(markdown-mode nil markdown-elixir))
(add-to-list 'mmm-mode-ext-classes-alist '(markdown-mode nil markdown-js))

(defun window-set-resize-to (percent)
  "Resize window to the specified PERCENT.  Expects PERCENT as 0.6."
  (interactive)
  (window-resize nil (- (truncate (* percent (frame-width))) (window-width)) t))

(defun split-half ()
  "Resize window to equal split."
  (interactive)
  (window-set-resize-to 0.5))

(defun split-60-40 ()
  "Resize window to equal split."
  (interactive)
  (window-set-resize-to 0.6))

;; use xclip to copy/paste in emacs-nox
(unless window-system
  (when (getenv "DISPLAY")
    (defun xclip-cut-function (text &optional push)
      (with-temp-buffer
	(insert text)
	(call-process-region (point-min) (point-max) "xclip" nil 0 nil "-i" "-selection" "clipboard")))
    (defun xclip-paste-function()
      (let ((xclip-output (shell-command-to-string "xclip -o -selection clipboard")))
	(unless (string= (car kill-ring) xclip-output)
	  xclip-output )))
    (setq interprogram-cut-function 'xclip-cut-function)
    (setq interprogram-paste-function 'xclip-paste-function)
    ))

(require 'evil-terminal-cursor-changer)
(evil-terminal-cursor-changer-activate)
(setq evil-visual-state-cursor '("red" box))
(setq evil-normal-state-cursor '("red" box))
(setq evil-insert-state-cursor '("green" bar))
(setq evil-emacs-state-cursor '("green" box))

(setq custom-file (expand-file-name "customize.el" user-emacs-directory))
(load custom-file)

(provide 'anything-bundle)
;;; anything-bundle.el ends here
