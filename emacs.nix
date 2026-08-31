{ pkgs, ... }:

{
  programs.doom-emacs = {
    enable = true;
    doomDir = ./doom.d;
    emacs = pkgs.emacs-gtk;
    extraBinPackages = with pkgs; [
      emacs-lsp-booster
      haskellPackages.hoogle
      shellcheck
      shfmt
      gnumake
      cmake
      nixfmt
      deno
      prettier
      vscode-langservers-extracted
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
