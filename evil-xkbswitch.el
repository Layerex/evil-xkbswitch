;;; evil-xkbswitch.el --- Input method switching corresponds to current state.

(defvar evil-xkbswitch-set-layout (if (eq system-type 'darwin) "issw" "xkb-switch -s")
  "Set xkb layout.")
(defvar evil-xkbswitch-get-layout (if (eq system-type 'darwin) "issw" "xkb-switch")
  "Get xkb layout.")
(defvar evil-xkbswitch--us-method (if (eq system-type 'darwin) "com.apple.keylayout.US" "us")
  "US input method.")
(defvar evil-xkbswitch--last-method nil
  "Last input method.")
(defvar evil-xkbswitch-verbose nil
  "Verbose?")

(defun evil-xkbswitch-to-us ()
  "Switch input method to US.
Save last method into `evil-xkbswitch--last-method'."
  (interactive)
  (setq evil-xkbswitch--last-method
        (replace-regexp-in-string "\n" ""
          (shell-command-to-string
            (format "%s" evil-xkbswitch-get-layout))))
  (shell-command-to-string (format "%s '%s'"
                                   evil-xkbswitch-set-layout
                                   evil-xkbswitch--us-method))
  (when evil-xkbswitch-verbose
    (message "Current method (us) %s" evil-xkbswitch--us-method)))

(defun evil-xkbswitch-to-alternate ()
  "Restore last input method."
  (interactive)
  (when evil-xkbswitch--last-method
    (shell-command-to-string (format "%s '%s'"
                                     evil-xkbswitch-set-layout
                                     evil-xkbswitch--last-method)))
  (when evil-xkbswitch-verbose
    (message "Current method (alternate) %s" evil-xkbswitch--last-method)))

;;;###autoload
(define-minor-mode evil-xkbswitch-mode
  "Switch input."
  :global t
  :lighter " xkb"
  (if evil-xkbswitch-mode
      (progn
        (add-hook 'evil-insert-state-entry-hook #'evil-xkbswitch-to-alternate)
        (add-hook 'evil-insert-state-exit-hook #'evil-xkbswitch-to-us)
        (add-hook 'evil-replace-state-entry-hook #'evil-xkbswitch-to-alternate)
        (add-hook 'evil-replace-state-exit-hook #'evil-xkbswitch-to-us))
    (remove-hook 'evil-insert-state-entry-hook #'evil-xkbswitch-to-alternate)
    (remove-hook 'evil-insert-state-exit-hook #'evil-xkbswitch-to-us)
    (remove-hook 'evil-replace-state-entry-hook #'evil-xkbswitch-to-alternate)
    (remove-hook 'evil-replace-state-exit-hook #'evil-xkbswitch-to-us)))

(define-global-minor-mode global-evil-xkbswitch-mode evil-xkbswitch-mode evil-xkbswitch-mode)

(provide 'evil-xkbswitch)
