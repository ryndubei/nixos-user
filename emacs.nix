{ pkgs, config, ... }:

{
  programs.doom-emacs = {
    enable = true;
    doomDir = ./doom.d;
    doomLocalDir = "${config.home.homeDirectory}/.local/share/nix-doom";
    tangleArgs = "--all config.org"; # build literate config
    emacs = pkgs.unstable.emacs-pgtk;
    extraPackages = epkgs: [ epkgs.treesit-grammars.with-all-grammars ];

    emacsPackageOverrides = k: p: {
      # https://github.com/org-noter/org-noter/issues/66#issuecomment-2483338143
      org-noter = p.org-noter.overrideAttrs (old: {
        postInstall = (builtins.replaceStrings [ "batch-native-compile" ] [ "ignore" ] old.postInstall);
      });
      ghostel = pkgs.unstable.emacsPackages.ghostel.overrideAttrs (old: {
        version = "0.59.0";
        src = old.src.override {
          hash = "sha256-1eIMfkPrczsirteuN3uM4axj8ZW3pt0TpPG+Lpos2uU=";
        };
        zigDeps = old.zigDeps.overrideAttrs {
          outputHash = "sha256-BZzOCIY/3kkpYN115YLeu8snFqW77cJBXF+z+cpNYLk=";
        };
      });
      evil-ghostel = p.evil-ghostel.overrideAttrs (old: {
        version = "0.59.0";
        src = k.ghostel.src;
      });
    };

    extraBinPackages = with pkgs; [
      # spell
      (aspellWithDicts (
        dicts: with dicts; [
          en
          en-computers
          en-science
          ru
        ]
      ))

      # grammar
      languagetool

      # latex
      texlab # +lsp

      mlocate # file search

      emacs-lsp-booster # lsp +booster
      haskellPackages.hoogle # haskell
      nixfmt # nix
      wl-clipboard # org-download
      graphviz # org-roam

      # arc-mode
      unzip
      zip

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
