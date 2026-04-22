;;; init-tab-bar-light-sun.el --- Tab bar configuration for light sun theme  -*- lexical-binding: t; -*-

;;; Commentary:
;; Tab bar faces and settings for light sun theme.

;;; Code:

;; Hide close button on tab-bar tabs
(setq tab-bar-close-button-show nil)

;; Function to set tab-bar faces - must use set-face-attribute AFTER theme loads
;; because custom-set-faces gets overridden by doom-themes
(defun my/set-tab-bar-faces ()
  "Set tab-bar faces. Call this after theme loads."
  (interactive)
  ;; Set default window background color - neutral dark with subtle warmth
  ;; (set-face-attribute 'default nil :background "#242222")
  ;; ;; Buffer separator (vertical border) - neutral gray
  ;; (set-face-attribute 'vertical-border nil
  ;;                     :foreground "#4a4545"
  ;;                     :background "#242222")
  ;; doom-solarized-light light brownish-gray
  (set-face-attribute 'vertical-border nil
                      :foreground "#E1DBCD"
                      :background "#E1DBCD")
  ;; Tab-bar container background
  (set-face-attribute 'tab-bar nil
                      :background "#ede0d5"
                      :foreground "#5a5555")
  ;; Active tab: fire gold text on warm earth background
  (set-face-attribute 'tab-bar-tab nil
                      :background "#f8efe7"
                      :foreground "#8e8791"
                      :weight 'bold
                      :underline nil
                      :box '(:line-width (6 . 4) :color "#f8efe7" :style nil))
  ;; Inactive tab: muted gray text on darker background
  (set-face-attribute 'tab-bar-tab-inactive nil
                      :background "#ede0d5"
                      :foreground "#5a5555"
                      :weight 'normal
                      :box '(:line-width (6 . 4) :color "#ede0d5" :style nil))
  ;; ;; Ivy-posframe styling - dark earth tones (only if loaded)
  ;; Ivy current match - light red
  (when (facep 'ivy-current-match)
    (set-face-attribute 'ivy-current-match nil :background "#ffcccc" :foreground "black" :extend t))
  (message "Tab-bar, mode-line, line-number and magit faces applied."))

;; Apply tab-bar faces now (after doom-themes loaded above)
(my/set-tab-bar-faces)

;; Re-apply when theme changes
(add-hook 'after-load-theme-hook #'my/set-tab-bar-faces)

;; Also apply after Emacs startup to override any late-loading packages
(add-hook 'emacs-startup-hook #'my/set-tab-bar-faces)

;; Apply after a short delay to override mode-line and other packages
(run-with-idle-timer 2 nil #'my/set-tab-bar-faces)

(provide 'init-tab-bar-light-sun)
;;; init-tab-bar-light-sun.el ends here
