;; @see http://cx4a.org/software/auto-complete/manual.html
(require 'auto-complete-config)
(require 'auto-complete-clang)

(global-auto-complete-mode t)
(setq ac-expand-on-auto-complete nil)
(setq ac-auto-start nil)
(setq ac-quick-help-delay 0.5)

(setq ac-dwim nil) ; To get pop-ups with docs even if a word is uniquely completed
(ac-set-trigger-key "TAB") ; AFTER input prefix, press TAB key ASAP


;echo "" | g++ -v -x c++ -E -
;(setq ac-clang-flags
      ;(mapcar (lambda (item)(concat "-I" item))
              ;(split-string
               ;"
;/opt/ros/jade/include
;/usr/include/c++/4.8
;/usr/include/x86_64-linux-gnu/c++/4.8
;/usr/include/c++/4.8/backward
;/usr/lib/gcc/x86_64-linux-gnu/4.8/include
;/usr/local/include
;/usr/lib/gcc/x86_64-linux-gnu/4.8/include-fixed
;/usr/include/x86_64-linux-gnu
;/usr/include
;"
               ;)))

(define-key ac-mode-map  [(tab)] 'auto-complete)
(defun my-ac-config ()
  (setq-default ac-sources '(ac-source-abbrev ac-source-dictionary ac-source-words-in-same-mode-buffers))
  (add-hook 'emacs-lisp-mode-hook 'ac-emacs-lisp-mode-setup)
  ;; (add-hook 'c-mode-common-hook 'ac-cc-mode-setup)
  (add-hook 'ruby-mode-hook 'ac-ruby-mode-setup)
  (add-hook 'css-mode-hook 'ac-css-mode-setup)
  (add-hook 'auto-complete-mode-hook 'ac-common-setup)
  (global-auto-complete-mode t))
(defun my-ac-cc-mode-setup ()
  (setq ac-sources (append '(ac-source-clang ac-source-yasnippet) ac-sources)))
(add-hook 'c-mode-common-hook 'my-ac-cc-mode-setup)
;; ac-source-gtags
(my-ac-config)


(defun ome-pkg-config-enable-clang-flag (pkg-config-lib)
  "This function will add necessary header file path of a
specified by `pkg-config-lib' to `ac-clang-flags', which make it
completionable by auto-complete-clang"
  (interactive "spkg-config lib: ")
  (if (executable-find "pkg-config")
      (if (= (shell-command
              (format "pkg-config %s" pkg-config-lib))
             0)
          (setq ac-clang-flags
                (append ac-clang-flags
                        (split-string
                         (shell-command-to-string
                          (format "pkg-config --cflags-only-I %s"
                                  pkg-config-lib)))))
        (message "Error, pkg-config lib %s not found." pkg-config-lib))
    (message "Error: pkg-config tool not found.")))

;; (ome-pkg-config-enable-clang-flag "QtGui")

(defun ome-auto-complete-clang-setup ()
  (require 'auto-complete-clang)
  (setq command "echo | g++ -v -x c++ -E - 2>&1 |
                 grep -A 20 starts | grep include | grep -v search")
  (setq ac-clang-flags
        (mapcar (lambda (item)
                  (concat "-I" item))
                (split-string
                 (shell-command-to-string command))))
  ;; completion for C/C++ macros.
  (push "-code-completion-macros" ac-clang-flags)
  (push "-code-completion-patterns" ac-clang-flags)
  (dolist (mode-hook '(c-mode-hook c++-mode-hook))
    (add-hook mode-hook
              (lambda ()
                (add-to-list 'ac-sources 'ac-source-clang)))))

(ome-auto-complete-clang-setup)
;(when (executable-find "clang")
  ;(ome-install 'auto-complete-clang))

;; Use C-n/C-p to select candidate ONLY when completion menu is displayed
;; Below code is copied from official manual
;(setq ac-use-menu-map t)
;; Default settings
;(define-key ac-menu-map "\C-n" 'ac-next)
;(define-key ac-menu-map "\C-p" 'ac-previous)
;; extra modes auto-complete must support
;(dolist (mode '(magit-log-edit-mode log-edit-mode org-mode text-mode haml-mode
                ;sass-mode yaml-mode csv-mode espresso-mode haskell-mode
                ;html-mode web-mode sh-mode smarty-mode clojure-mode
                ;lisp-mode textile-mode markdown-mode tuareg-mode
                ;js2-mode css-mode less-css-mode))
  ;(add-to-list 'ac-modes mode))

;; Exclude very large buffers from dabbrev
;(defun sanityinc/dabbrev-friend-buffer (other-buffer)
  ;(< (buffer-size other-buffer) (* 1 1024 1024)))

;(setq dabbrev-friend-buffer-function 'sanityinc/dabbrev-friend-buffer)

(ac-config-default)




;irony part
(require 'use-package)

(use-package irony
  :ensure t
  :defer t
  :init
  (add-hook 'c++-mode-hook 'irony-mode)
  (add-hook 'c-mode-hook 'irony-mode)
  (add-hook 'objc-mode-hook 'irony-mode)
  :config
  ;; replace the `completion-at-point' and `complete-symbol' bindings in
  ;; irony-mode's buffers by irony-mode's function
  (defun my-irony-mode-hook ()
    (define-key irony-mode-map [remap completion-at-point]
      'irony-completion-at-point-async)
    (define-key irony-mode-map [remap complete-symbol]
      'irony-completion-at-point-async))
  (add-hook 'irony-mode-hook 'my-irony-mode-hook)
  (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
  )

;; == company-mode ==
(use-package company
  :ensure t
  :defer t
  :init (add-hook 'after-init-hook 'global-company-mode)
  :config
  (use-package company-irony :ensure t :defer t)
  (setq company-idle-delay              nil
    company-minimum-prefix-length   2
    company-show-numbers            t
    company-tooltip-limit           20
    company-dabbrev-downcase        nil
    company-backends                '((company-irony company-gtags))
    )
  :bind ("C-;" . company-complete-common)
)

(provide 'init-auto-complete)
