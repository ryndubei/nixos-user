{ pkgs, config, ... }:

{
  programs.doom-emacs = {
    enable = true;
    doomDir = ./doom.d;
    doomLocalDir = "${config.home.homeDirectory}/.local/share/nix-doom";
    tangleArgs = "--all config.org"; # build literate config
    emacs = pkgs.unstable.emacs-pgtk;
    extraPackages = epkgs: [ epkgs.treesit-grammars.with-all-grammars ];
    extraBinPackages = with pkgs; [
      findutils # file search

      emacs-lsp-booster # lsp +booster
      haskellPackages.hoogle # haskell
      nixfmt # nix
      wl-clipboard # org-download
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
    startWithUserSession = "graphical";
  };
}
