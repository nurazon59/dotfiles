(use-package rose-pine-moon-theme
  :vc (:url "https://github.com/thongpv87/rose-pine-emacs"
	    :rev :newest
	    :main-file "rose-pine-moon-theme.el")
  :no-require t
  :config
  (load-theme 'rose-pine-moon t))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(rose-pine-moon-theme))
 '(package-vc-selected-packages
   '((rose-pine-moon-theme :url
			   "https://github.com/thongpv87/rose-pine-emacs"
			   :main-file "rose-pine-moon-theme.el"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(require 'treesit)
(require 'go-ts-mode)
(require 'markdown-ts-mode)

(dolist (language '(go markdown markdown-inline))
  (unless (treesit-language-available-p language)
    (treesit-install-language-grammar language)))
(add-to-list 'auto-mode-alist '("\\.go\\'" . go-ts-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-ts-mode))

(use-package eglot
  :ensure nil
  :hook (go-ts-mode . eglot-ensure))
