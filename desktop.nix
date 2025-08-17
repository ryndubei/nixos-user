{ pkgs, lib, anti-ip, ... }:

{
  home.packages = (with pkgs; [
    electrum
    evolution
    fira-code
    haskell-language-server
    jetbrains.idea-community
    legcord
    libreoffice
    mpv
    nerd-fonts.meslo-lg
    nixd
    protonmail-bridge
    qbittorrent
    signal-desktop
    telegram-desktop
    tor-browser
    ungoogled-chromium
    vaults
    zotero
  ]) ++ (with pkgs.gnomeExtensions; [ appindicator pop-shell system-monitor ]);

  fonts.fontconfig.enable = true;

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };

  # NOTE: custom module (services/protonmail-bridge.nix)
  services.protonmail-bridge.enable = true;

  services.flatpak = {
    enable = true;
    packages = [
      "com.github.tchx84.Flatseal"
      "org.prismlauncher.PrismLauncher"
      "md.obsidian.Obsidian"
      "com.usebottles.bottles"
      "com.spotify.Client"
    ];
  };

  # Symlink system runtimes to the user's flatpak installation
  home.activation.flatpakSymlinkSystemRuntimes =
    lib.hm.dag.entryBetween [ "flatpak-managed-install" ] [ "writeBoundary" ]
    (builtins.readFile scripts/flatpak-symlink-system-runtimes.sh);

  services.flatpak.overrides = {
    "md.obsidian.Obsidian".Context = {
      filesystems = [ "~/Documents/Notes" "!/run/media" "!/mnt" "!/media" ];
      shared = [ "!network" ];
    };
    "com.spotify.Client".Context = {
      filesystems = [
        "${anti-ip.libspotifyadblock}"
        "~/.config/spotify-adblock/config.toml"
      ];
    };
    "com.spotify.Client".Environment = {
      LD_PRELOAD = "${anti-ip.libspotifyadblock}/lib/libspotifyadblock.so";
    };
  };

  home.file.".config/spotify-adblock/config.toml".source =
    "${anti-ip.spotify-adblock-source}/config.toml";

  programs.neovim.extraLuaConfig = ''
    require('lspconfig')['hls'].setup{
      filetypes = { 'haskell', 'lhaskell', 'cabal' },
    }
    require'lspconfig'.nixd.setup{}
  '';
  programs.neovim.plugins = with pkgs.vimPlugins; [ nvim-lspconfig ];

  dconf.settings = lib.mkMerge [
    {
      "org/gnome/shell" = {
        enabled-extensions = map (extension: extension.extensionUuid)
          (with pkgs.gnomeExtensions; [
            appindicator
            pop-shell
            system-monitor
          ]);
        disabled-extensions = [ ];
        favorite-apps = [
          "librewolf.desktop"
          "org.gnome.Nautilus.desktop"
          "org.gnome.Console.desktop"
          "codium.desktop"
        ];
      };

      "org/gnome/desktop/interface" = {
        # Dark colour scheme
        color-scheme = "prefer-dark";

        enable-hot-corners = false;
      };

      # Expandable folders in list view
      "org/gnome/nautilus/list-view".use-tree-view = true;
      # Create Link context menu action
      "org/gnome/nautilus/preferences".show-create-link = true;

      # Disable mouse acceleration
      "org/gnome/desktop/peripherals/mouse".accel-profile = "flat";

      # Touchpad scrolls the view instead of the content
      "org/gnome/desktop/peripherals/touchpad".natural-scroll = false;

      # Enable MesloLGS font in GNOME Console
      "org/gnome/Console".use-system-font = false;
      "org/gnome/Console".custom-font = "MesloLGS Nerd Font Mono 10";
    }
    # Match pop-shell keybindings
    (import data/pop-shell-keybindings.nix)
  ];

  gtk.theme = {
    name = "Adwaita-dark";
    package = pkgs.gnome-themes-extra;
  };

  programs.looking-glass-client.enable = true;
  # Use system installation, if present, otherwise don't install
  programs.looking-glass-client.package = pkgs.emptyDirectory;
  programs.looking-glass-client.settings = {
    app.shmFile = "/dev/kvmfr0";
    win = {
      fullScreen = true;

      # so that the window doesn't break with pop-shell tiling
      maximize = true;

      # Prevent screensaver from starting when guest requests it
      autoScreensaver = true;
    };
    input = { rawMouse = true; };
  };

  programs.librewolf = {
    enable = true;
    settings = {
      "browser.safebrowsing.malware.enabled" = true;
      "browser.safebrowsing.phishing.enabled" = true;
      "browser.safebrowsing.blockedURIs.enabled" = true;
      "browser.safebrowsing.provider.google4.gethashURL" =
        "https://safebrowsing.googleapis.com/v4/threatListUpdates:fetch?$ct=application/x-protobuf&key=%GOOGLE_SAFEBROWSING_API_KEY%&$httpMethod=POST";
      "browser.safebrowsing.provider.google.gethashURL" =
        "https://safebrowsing.google.com/safebrowsing/gethash?client=SAFEBROWSING_ID&appver=%MAJOR_VERSION%&pver=2.2";
      "browser.safebrowsing.provider.google.updateURL" =
        "https://safebrowsing.google.com/safebrowsing/downloads?client=SAFEBROWSING_ID&appver=%MAJOR_VERSION%&pver=2.2&key=%GOOGLE_SAFEBROWSING_API_KEY%";
      "privacy.resistFingerprinting.letterboxing" = true;
      "network.http.referer.XOriginPolicy" = 2;
      "identity.fxaccounts.enabled" = true;
      "privacy.clearOnShutdown.history" = false;
      "privacy.clearOnShutdown.downloads" = false;
      "middlemouse.paste" = false;
      "general.autoScroll" = true;
    };
  };

  # Unfree package exceptions
  nixpkgs.config.allowUnfreePredicate = let
    whitelist = map lib.getName (with pkgs; [
      aseprite
      vscode-extensions.github.copilot
      vscode-extensions.github.copilot-chat
    ]);
  in pkg: builtins.elem (lib.getName pkg) whitelist;

  home.file.".ideavimrc".text = ''
    set relativenumber
    set number
  '';

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    mutableExtensionsDir = false;
    profiles.default.extensions = (with pkgs.vscode-extensions; [
      haskell.haskell
      github.copilot
      github.copilot-chat
      justusadam.language-haskell
      mads-hartmann.bash-ide-vscode
      mkhl.direnv
      ms-python.python
      ms-pyright.pyright
      jnoortheen.nix-ide
      llvm-vs-code-extensions.vscode-clangd
      scala-lang.scala
      sumneko.lua
      teabyii.ayu
      twxs.cmake
      usernamehw.errorlens
      vscodevim.vim
    ]) ++ (pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "lean4";
        publisher = "leanprover";
        version = "0.0.178";
        sha256 = "sha256-ByhiTGwlQgNkFf0BirO+QSDiXbQfR6RLQA8jM4B1+O4=";
      }
      {
        name = "gitless";
        publisher = "maattdd";
        version = "11.7.2";
        sha256 = "sha256-rYeZNBz6HeZ059ksChGsXbuOao9H5m5lHGXJ4ELs6xc=";
      }
    ]);
    profiles.default.userSettings = {
      "haskell.manageHLS" = "PATH";
      "git.enableSmartCommit" = true;
      "window.menuBarVisibility" = "toggle";
      "workbench.preferredDarkColorTheme" = "Ayu Dark Bordered";
      "workbench.colorTheme" = "Ayu Dark Bordered";
      "window.autoDetectColorScheme" = true;
      "vim.handleKeys" = {
        "<C-k>" = false;
        "<C-b>" = false;
      };
      "editor.lineNumbers" = "relative";
      "workbench.panel.defaultLocation" = "right";
      "editor.fontFamily" =
        "'Fira Code', 'Droid Sans Mono', 'monospace', monospace";
      # Enable MesloLGS in the VSCodium integrated terminal
      "terminal.integrated.fontFamily" =
        "'MesloLGS Nerd Font Mono', 'Fira Code', 'Droid Sans Mono', 'monospace'";
      "editor.fontLigatures" = true;
      "[haskell]" = {
        "editor.defaultFormatter" = "haskell.haskell";
        "editor.tabSize" = 2;
        "editor.detectIndentation" = false;
        "editor.fontLigatures" = "'ss09'";
      };
      "[literate haskell]" = {
        "editor.defaultFormatter" = "haskell.haskell";
        "editor.tabSize" = 2;
        "editor.detectIndentation" = false;
        "editor.wordWrap" = "on";
        "editor.fontLigatures" = "'ss09'";
      };
      "[latex]"."editor.wordWrap" = "on";
      "editor.inlineSuggest.enabled" = true;
      "github.copilot.enable" = {
        "*" = true;
        "plaintext" = false;
        "markdown" = false;
        "yaml" = false;
        "toml" = false;
        "secret" = false;
      };
      "git.autofetch" = true;
      "haskell.formattingProvider" = "fourmolu";
      "workbench.localHistory.exclude" = { "*.secret" = true; };
      "workbench.preferredLightColorTheme" = "Quiet Light";
      "git.openRepositoryInParentFolders" = "never";
      "errorLens.removeLinebreaks" = false;
      "gitlens.telemetry.enabled" = false;
      "github.copilot.editor.enableAutoCompletions" = true;
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nixd";
      "direnv.restart.automatic" = true;
      "haskell.plugin.notes.globalOn" = true;
      "[nix]".editor.formatOnSave = true;
      "diffEditor.ignoreTrimWhitespace" = false;
      "notebook.lineNumbers" = "on";
      "python.languageServer" = "Jedi";
      "lean4.alwaysShowTitleBarMenu" = false;
      "terminal.integrated.defaultProfile.linux" = "fish";
    };
  };
}

