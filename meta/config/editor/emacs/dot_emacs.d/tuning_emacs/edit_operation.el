;backup file at temporary dir.
(setq make-backup-files nil)
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))



;screen display and scroll screen
(setq redisplay-dont-pause t
  scroll-margin 3
  scroll-step 1
  scroll-conservatively 10000
  scroll-preserve-screen-position 1)


;disable auto-save
(auto-save-mode nil)

;GC
(setq gc-cons-threshold 134217728)  ;128MB for GC
(setq inhibit-startup-message t)


;loading huge file warning
(setq large-file-warning-threshold nil) ;never to request


(set-face-attribute 'default nil :height 130)

;cscope
(require 'xcscope)

;set c mode tab width to 4
(setq-default c-basic-offset 4
              tab-width 4
              indent-tabs-mode t)
