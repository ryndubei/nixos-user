{
  programs.emacs = {
    enable = true;
    extraPackages =
      p: with p; [
        evil
        evil-collection
        magit
      ];
    extraConfig = ''
      (use-package evil
        :ensure t
        :init
        (setq evil-want-integration t)
        (setq evil-want-keybinding nil)
        (setq evil-want-C-u-scroll t)
        :config
        (evil-mode 1))

      (use-package evil-collection
        :after evil
        :ensure t
        :config
        (evil-collection-init))

      (setq display-line-numbers-type 'relative)
      (add-hook 'prog-mode-hook 'display-line-numbers-mode)
    '';
  };

  # Fixes C-h i info index
  programs.info.enable = true;

  services.emacs = {
    enable = true;
    client.enable = true; # Generate desktop file for client
    socketActivation.enable = true; # Launch daemon lazily
  };
}
