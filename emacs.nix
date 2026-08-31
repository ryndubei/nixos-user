{ pkgs, ... }:

{
  programs.doom-emacs = {
    enable = true;
    doomDir = ./doom.d;
    emacs = pkgs.emacs-pgtk;
    extraBinPackages = [
      pkgs.emacs-lsp-booster
      pkgs.haskellPackages.hoogle
      pkgs.shellcheck
      pkgs.gnumake
      pkgs.cmake
      pkgs.nixfmt
    ];
  };

  # Fixes C-h i info index
  programs.info.enable = true;

  services.emacs = {
    enable = true;
    client.enable = true; # Generate desktop file for client
    socketActivation.enable = true; # Launch daemon lazily
  };
}
