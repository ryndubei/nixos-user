{ pkgs, lib, config, anti-ip, ... }:

{
  home.packages = (with pkgs; [
    armcord
    aseprite
    electrum
    fira-code
    haskell-language-server
    logseq
    mpv
    (nerdfonts.override { fonts = [ "Meslo" ]; })
    nixd
    onedriver
    # protonmail-bridge
    qbittorrent
    # thunderbird
    vaults
  ]) ++ (with pkgs.gnomeExtensions; [
    appindicator
    pop-shell
    system-monitor
  ]);

  nixpkgs.config.permittedInsecurePackages = [
    # logseq dependency, marked insecure due to EOL
    "electron-27.3.11"
  ];

  fonts.fontconfig.enable = true;

  services.flatpak = {
    enable = true;
    packages = [
      "com.valvesoftware.Steam"
      "com.github.tchx84.Flatseal"
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
      filesystems = [
        "~/Documents/Notes"
        "!/run/media"
        "!/mnt"
        "!/media"
      ];
      shared = [ "!network" ];
    };
    "com.valvesoftware.Steam".Context = {
      filesystems = [
        "!xdg-music"
        "!xdg-pictures"
        "/mnt/hard_drive/data/${config.home.username}/Games_(slow)/Steam_Library"
        "${anti-ip.libstellarkey}:ro"
      ];
    };
    "com.valvesoftware.Steam".Environment = {
      # add LD_PRELOAD="$STELLARKEY_PATH:$LD_PRELOAD" %command% to launch options to use
      "STELLARKEY_PATH" = "${anti-ip.libstellarkey}/lib/libstellarkey.so";
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

  home.file.".config/spotify-adblock/config.toml".source = "${anti-ip.spotify-adblock-source}/config.toml";

  # Run apply-smokeapi on startup
  # TODO: move this to a Steam desktop file
  systemd.user.services.apply-smokeapi =
    (
      let
        # The appids (ints)/names (strings) we are attempting to patch
        apps = [ "Imperator: Rome" ];
      in
      {
        Unit.Description = "Apply SmokeAPI";
        Install.WantedBy = [ "graphical-session.target" ];
        Service = {
          Type = "oneshot";
          ExecStart = "${anti-ip.apply-smokeapi apps}/bin/apply-smokeapi";
        };
      }
    );

  # Run apply-smokeapi on home-manager activation as well
  home.activation.startApplySmokeapi = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run /run/current-system/sw/bin/systemctl start --user apply-smokeapi.service
  '';

  programs.neovim.extraLuaConfig = ''
    require('lspconfig')['hls'].setup{
      filetypes = { 'haskell', 'lhaskell', 'cabal' },
    }
    require'lspconfig'.nixd.setup{}
  '';
  programs.neovim.plugins = with pkgs.vimPlugins; [
    nvim-lspconfig
  ];

  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = map (extension: extension.extensionUuid) (with pkgs.gnomeExtensions; [
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

    # GNOME keybindings
    "org/gnome/settings-daemon/plugins/media-keys" = {
      # Open default web browser
      www = [ "<Super>b" ];
      custom-keybindings = [ "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/" ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Open Terminal";
      command = "kgx";
      binding = "<Super>t";
    };
    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Super>q" ];
      toggle-maximized = [ "<Super>m" ];

      # Redundant with the toggle-maximized keybinding
      maximize = [ ];
      minimize = [ ];
    };
    # Remove open notifications keybinding (default is Super+B, but we want to
    # use it to open the browser) 
    "org/gnome/shell/keybindings".toggle-message-tray = [ ];

    # Enable MesloLGS font in GNOME Console
    "org/gnome/Console".use-system-font = false;
    "org/gnome/Console".custom-font = "MesloLGS Nerd Font Mono 10";
  };

  programs.looking-glass-client.enable = true;
  programs.looking-glass-client.settings = {
    app.shmFile = "/dev/kvmfr0";
    win = {
      fullScreen = true;

      # so that the window doesn't break with pop-shell tiling
      maximize = true;

      # Prevent screensaver from starting when guest requests it
      autoScreensaver = true;
    };
    input = {
      rawMouse = true;
    };
  };

  programs.librewolf = {
    enable = true;
    settings = {
      "browser.safebrowsing.malware.enabled" = true;
      "browser.safebrowsing.phishing.enabled" = true;
      "browser.safebrowsing.blockedURIs.enabled" = true;
      "browser.safebrowsing.provider.google4.gethashURL" = "https://safebrowsing.googleapis.com/v4/threatListUpdates:fetch?$ct=application/x-protobuf&key=%GOOGLE_SAFEBROWSING_API_KEY%&$httpMethod=POST";
      "browser.safebrowsing.provider.google.gethashURL" = "https://safebrowsing.google.com/safebrowsing/gethash?client=SAFEBROWSING_ID&appver=%MAJOR_VERSION%&pver=2.2";
      "browser.safebrowsing.provider.google.updateURL" = "https://safebrowsing.google.com/safebrowsing/downloads?client=SAFEBROWSING_ID&appver=%MAJOR_VERSION%&pver=2.2&key=%GOOGLE_SAFEBROWSING_API_KEY%";
      "privacy.resistFingerprinting.letterboxing" = true;
      "network.http.referer.XOriginPolicy" = 2;
      "identity.fxaccounts.enabled" = true;
      "privacy.clearOnShutdown.history" = false;
      "privacy.clearOnShutdown.downloads" = false;
      "middlemouse.paste" = false;
      "general.autoScroll" = true;
    };
  };

  services.syncthing = {
    enable = true;
    # tray.enable = true;
    # tray.package = pkgs.syncthingtray-minimal;
  };

  # Let home-manager manage the xsession
  xsession.enable = true;

  # Unfree package exceptions
  nixpkgs.config.allowUnfreePredicate =
    let
      whitelist = map lib.getName (with pkgs; [
        aseprite
        vscode-extensions.github.copilot
        vscode-extensions.github.copilot-chat
      ]);
    in
    pkg: builtins.elem (lib.getName pkg) whitelist;

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    mutableExtensionsDir = false;
    extensions = (with pkgs.vscode-extensions; [
      haskell.haskell
      github.copilot
      github.copilot-chat
      justusadam.language-haskell
      mads-hartmann.bash-ide-vscode
      mkhl.direnv
      ms-python.python
      jnoortheen.nix-ide
      teabyii.ayu
      usernamehw.errorlens
      vscodevim.vim
    ]) ++ (pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      #{
      #  name = "agda-mode";
      #  publisher = "banacorn";
      #  version = "0.4.7";
      #  sha256 = "80d6b79f5ea53f7a28051bc66ae813b9ae085dc233a4c93b8c160c24342c634d";
      #}
      {
        name = "gitless";
        publisher = "maattdd";
        version = "11.7.2";
        sha256 = "sha256-rYeZNBz6HeZ059ksChGsXbuOao9H5m5lHGXJ4ELs6xc=";
      }
    ]);
    userSettings = {
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
      "editor.fontFamily" = "'Fira Code', 'Droid Sans Mono', 'monospace', monospace";
      # Enable MesloLGS in the VSCodium integrated terminal
      "terminal.integrated.fontFamily" = "'MesloLGS Nerd Font Mono', 'Fira Code', 'Droid Sans Mono', 'monospace'";
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
      "workbench.localHistory.exclude" = {
        "*.secret" = true;
      };
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
    };
  };
}

