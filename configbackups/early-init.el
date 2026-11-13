;;; early-init.el --- Pre-init frame configuration -*- lexical-binding: t -*-

(setq-default default-directory "~/")

(dolist (buf '("*scratch*" "*Messages*"))
  (when (get-buffer buf)
    (with-current-buffer buf
      (setq default-directory "~/"))))

(add-to-list 'default-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(font . "Roboto Mono-14"))
(provide 'early-init)
;;; early-init.el ends here
