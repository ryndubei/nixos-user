{ pkgs, lib, config, libstellarkey, libspotifyadblock, spotify-adblock-source, apply-smokeapi, smokeapi, ... }:

{
  home.packages = (with pkgs; [
    armcord
    aseprite
    electrum
    fira-code
    gnome.cheese
    haskell-language-server
    logseq
    mpv
    nixd
    # protonmail-bridge
    qbittorrent
    # thunderbird
    vaults
    zettlr
  ]) ++ (with pkgs.gnomeExtensions; [
    appindicator
    pop-shell
    system-monitor
  ]);

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
        "${libstellarkey}:ro"
        "${smokeapi}:ro"
      ];
    };
    "com.valvesoftware.Steam".Environment = {
      # add LD_PRELOAD="$STELLARKEY_PATH:$LD_PRELOAD" %command% to launch options to use
      "STELLARKEY_PATH" = "${libstellarkey}/lib/libstellarkey.so";
    };
    "com.spotify.Client".Context = {
      filesystems = [
        "${libspotifyadblock}"
        "~/.config/spotify-adblock/config.toml"
      ];
    };
    "com.spotify.Client".Environment = {
      LD_PRELOAD = "${libspotifyadblock}/lib/libspotifyadblock.so";
    };
  };

  home.file.".config/spotify-adblock/config.toml".source = "${spotify-adblock-source}/config.toml";

  # Run apply-smokeapi on startup
  # TODO: move this to a Steam desktop file
  systemd.user.services.apply-smokeapi =
    (
      let
        # The appids (ints)/names (strings) we are attempting to patch
        apps = [ "Victoria 3" "Hearts of Iron IV" "Crusader Kings III" "Stellaris" "Europa Universalis IV" ];
      in
      {
        Unit.Description = "Apply SmokeAPI";
        Install.WantedBy = [ "graphical-session.target" ];
        Service = {
          Type = "oneshot";
          ExecStart = "${apply-smokeapi apps}/bin/apply-smokeapi";
        };
      }
    );

  # Run apply-smokeapi on home-manager activation as well
  home.activation.startApplySmokeapi = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    /run/current-system/sw/bin/systemctl start --user apply-smokeapi.service
  '';

  programs.neovim.extraLuaConfig = ''
    require('lspconfig')['hls'].setup{
      filetypes = { 'haskell', 'lhaskell', 'cabal' },
    }
    require'lspconfig'.nixd.setup{}
  '';
  programs.neovim.plugins = with pkgs.vimPlugins; [
    (nvim-treesitter.withPlugins (p: [ p.haskell p.nix ]))
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
    };
    "org/gnome/desktop/peripherals/mouse".accel-profile = "flat";
    "org/gnome/desktop/peripherals/touchpad".natural-scroll = false;

    # GNOME keybindings
    "org/gnome/desktop/settings-daemon/plugins/media-keys" = {
      www = [ "<Super>b" ];
      screensaver = [ ];
    };
    "org/gnome/desktop/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Open Terminal";
      command = "kgx";
      binding = "<Super>t";
    };
    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Super>q" ];
      toggle-maximized = [ "<Super>m" ];
      maximize = [ ];
      minimize = [ ];
    };
    "org/gnome/shell/keybindings".toggle-message-tray = [ ];
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
