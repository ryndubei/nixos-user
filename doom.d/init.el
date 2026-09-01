;;; $DOOMDIR/init.el -*- lexical-binding: t; -*-

;; This file controls what Doom modules are enabled and what order they load
;; in. Remember to run 'doom sync' after modifying it!

(doom!
       :completion
       (corfu +orderless)
       vertico

       :ui
       doom
       dashboard
       hl-todo
       modeline
       ophints
       (popup +defaults)
       smooth-scroll
       treemacs
       (vc-gutter +pretty)
       vi-tilde-fringe
       workspaces

       :editor
       (evil +everywhere)
       file-templates
       fold
       (format +lsp)
       snippets
       (whitespace +guess +trim)

       :emacs
       dired
       electric
       tramp
       undo
       vc

       :term
       vterm

       :checkers
       syntax

       :tools
       direnv
       (eval +overlay)
       lookup
       (lsp +eglot +booster)
       magit
       pdf
       tree-sitter

       :os
       (:if (featurep :system 'macos) macos)  ; improve compatibility with macOS

       :lang
       emacs-lisp
       (haskell +lsp)
       (javascript +lsp +tree-sitter)
       markdown
       (nix +lsp)
       (org +dragndrop +noter +pretty +roam)
       (sh +fish)
       (web +lsp)

       :config
       (default +bindings +smartparens))
