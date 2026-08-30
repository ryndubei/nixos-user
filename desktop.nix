{
  pkgs,
  lib,
  config,
  ...
}:

{
  home.packages =
    (with pkgs; [
      altus
      authenticator
      electrum
      element-desktop
      fira-code
      fira-sans
      foliate
      legcord
      libreoffice
      mpv
      nerd-fonts.meslo-lg
      nerd-fonts.symbols-only
      protonmail-bridge
      qbittorrent
      signal-desktop
      symbola # emacs fallback font
      telegram-desktop
      tor-browser
      vaults
      xournalpp
      zotero
    ])
    ++ (with pkgs.gnomeExtensions; [
      appindicator
      # https://github.com/NixOS/nixpkgs/pull/529026
      (pop-shell.overrideAttrs {
        version = "1.2.0-unstable-2026-03-31";
        src = pkgs.fetchFromGitHub {
          owner = "pop-os";
          repo = "shell";
          rev = "7898b65c20735057faf0797f8ed056704ca55f0d";
          hash = "sha256-MmHoOxymo0QSRbRcSbFiv82+QWAwIwXwg/wyGQGVYiI=";
        };
      })
      system-monitor
    ]);

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      (lib.getName pkgs.symbola)
    ];

  fonts.fontconfig.enable = true;

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };

  # NOTE: custom module (services/protonmail-bridge.nix)
  custom.services.protonmail-bridge.enable = true;

  services.flatpak = {
    enable = true;
    packages = [
      "com.github.tchx84.Flatseal"
      "org.prismlauncher.PrismLauncher"
      "md.obsidian.Obsidian"
      "com.usebottles.bottles"
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
    "com.usebottles.bottles".Context = {
      filesystems = [
        "~/.var/app/com.valvesoftware.Steam"
        "/mnt/hard_drive/data/${config.home.username}/Games_(slow)/Steam_Library"
      ];
    };
  };

  dconf.settings = lib.mkMerge [
    {
      "org/gnome/shell" = {
        enabled-extensions = map (extension: extension.extensionUuid) (
          with pkgs.gnomeExtensions;
          [
            appindicator
            pop-shell
            system-monitor
          ]
        );
        disabled-extensions = [ ];
        favorite-apps = [
          "librewolf.desktop"
          "org.gnome.Nautilus.desktop"
          "org.gnome.Console.desktop"
          "emacsclient.desktop"
        ];
      };

      "org/gnome/desktop/interface" = {
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

  xdg.autostart.enable = true;
  xdg.autostart.readOnly = true;
  xdg.autostart.entries = [
    "${pkgs.signal-desktop}/share/applications/signal.desktop"
    "${pkgs.legcord}/share/applications/legcord.desktop"
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
    input = {
      rawMouse = true;
    };
  };

  programs.librewolf = {
    enable = true;
    settings = {
      "network.http.referer.XOriginPolicy" = 2;
      "identity.fxaccounts.enabled" = true;
      "privacy.clearOnShutdown.history" = false;
      "privacy.clearOnShutdown.downloads" = false;
      "middlemouse.paste" = false;
      "general.autoScroll" = true;
    };
  };

  programs.chromium = {
    enable = true;
    extensions =
      let
        browserVersion = lib.versions.major pkgs.ungoogled-chromium.version;
      in
      [
        rec {
          # uBlock Origin Lite
          # https://discourse.nixos.org/t/home-manager-ungoogled-chromium-with-extensions/15214/7
          id = "ddkjiahejlhfcafbddmgiahcphecmpfh";
          crxPath = pkgs.fetchurl {
            url = "https://clients2.google.com/service/update2/crx?response=redirect&acceptformat=crx2,crx3&prodversion=${browserVersion}&x=id%3D${id}%26installsource%3Dondemand%26uc";
            hash = "sha256-QrYLqJjMtC6rke8CAoz1xqPwKuoUMDyvEZl2+X7Nz10=";
          };
          version = "2026.825.1619";
        }
      ];
    package = pkgs.ungoogled-chromium;
  };

  home.file.".ideavimrc".text = ''
    set relativenumber
    set number
  '';

}
