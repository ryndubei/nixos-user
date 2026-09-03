{ pkgs, ... }:

{
  programs.doom-emacs = {
    enable = true;
    doomDir = ./doom.d;
    tangleArgs = "--all config.org"; # build literate config

    /*
    Must disable native compilation due to https://github.com/org-noter/org-noter/issues/66

    We use nix-doom-emacs-unstraightened, which does not expose an easy way to
    override packages in the Emacs overlay that it uses. So instead of disabling
    native compilation for org-noter only, we have to disable it everywhere like
    this:

    https://github.com/nix-community/emacs-overlay/issues/369#issuecomment-4427696458
    */
    emacs = pkgs.emacs-gtk.overrideAttrs (old: {
      passthru = old.passthru // {
        withNativeCompilation = false;
      };
    });

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
