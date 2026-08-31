{ pkgs, ... }:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
    extraPackages =
      p: with p; [
        evil
        evil-collection
        magit
      ];
  };

  # Fixes C-h i info index
  programs.info.enable = true;

  services.emacs = {
    enable = true;
    client.enable = true; # Generate desktop file for client
    socketActivation.enable = true; # Launch daemon lazily
  };

  home.file.".emacs.d/init.el".source = dotfiles/emacs.d/init.el;
}
