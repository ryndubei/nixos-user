{ pkgs, ... }:

{
  programs.doom-emacs = {
    enable = true;
    doomDir = ./doom.d;
    emacs = pkgs.emacs-gtk;
    extraPackages = epkgs: [ epkgs.treesit-grammars.with-all-grammars ];
    extraBinPackages = with pkgs; [
      findutils # file search

      emacs-lsp-booster # lsp +booster
      haskellPackages.hoogle # haskell
      nixfmt # nix
      wl-clipboard-rs # org-download
      graphviz # org-roam

      # vterm
      gnumake
      cmake

      # sh
      shellcheck
      shfmt

      # javascript
      deno
      prettier

      # web
      html-tidy
      stylelint
      js-beautify
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
