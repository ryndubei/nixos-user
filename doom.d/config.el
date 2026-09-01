;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:

(setq doom-font (font-spec :family "Fira Code" :weight 'semi-light)
      doom-variable-pitch-font (font-spec :family "Fira Sans"))

;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!


(setq doom-theme 'doom-one)

(setq display-line-numbers-type 'relative)

(setq org-directory "~/Documents/Notes/org")

;; Expand using a single click in Treemacs instead of a double click
(after! treemacs
  (map! :map treemacs-mode-map [mouse-1] #'treemacs-single-click-expand-action))


;; Russian keyboard layout compatibility
(use-package! reverse-im
  :after char-fold
  :custom
  ;; cache keymaps
  (reverse-im-cache-file (locate-user-emacs-file "reverse-im-cache.el"))
  ;; lax matching (can search in the wrong layout)
  (reverse-im-char-fold t)
  ;; ;; fix input for packages that use custom dispatchers via read-char
  ;; ;; (e.g. mu4e)
  ;; (reverse-im-read-char-advice-function #'reverse-im-read-char-include)
  ;; (reverse-im-input-methods '("russian-computer"))
  :config
  (reverse-im-mode t))

(use-package! char-fold
  :defer t
  :custom
  (char-fold-symmetric t)
  (search-default-mode #'char-fold-to-regexp))
