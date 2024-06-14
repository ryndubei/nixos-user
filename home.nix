{ pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "vasilysterekhov";
  home.homeDirectory = "/home/vasilysterekhov";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = (with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    armcord
    # agda
    aseprite
    bat
    blesh
    cryfs
    electrum
    element-desktop
    fira-code
    ghc
    gnome.cheese
    gocryptfs
    haskell-language-server
    logseq
    nixd
    pfetch
    # protonmail-bridge
    qbittorrent
    ripgrep
    # thunderbird
    tree
    vaults
    yt-dlp
    zettlr
    ((vim_configurable.override { }).customize{
      name = "vim";
      vimrcConfig.packages.myplugins = with vimPlugins; {
        start = [ vim-nix vim-lastplace ];
        opt = []; 
      };  
      vimrcConfig.customRC = ''
        set nocompatible
        set backspace=indent,eol,start
        syntax on
        set relativenumber
        set expandtab
        set tabstop=4
        set swapfile
        set dir=/tmp
        set number
      '';
    })  
  ]) ++ (with pkgs.gnomeExtensions; [
    appindicator
    pop-shell
    system-monitor
  ]);

  dconf.settings = {
    "org/gnome/shell" = {
        enabled-extensions = map (extension: extension.extensionUuid) (with pkgs.gnomeExtensions; [ 
          appindicator
          pop-shell
          system-monitor
        ]);
        disabled-extensions = [];
    };
    "org/gnome/desktop/peripherals/mouse".accel-profile = "flat";
    "org/gnome/desktop/peripherals/touchpad".natural-scroll = false;
  };

  services.syncthing = {
    enable = true;
    # tray.enable = true;
    # tray.package = pkgs.syncthingtray-minimal;
  };

  programs.git = {
    enable = true;
    userName = "ryndubei";
    userEmail = "114586905+ryndubei@users.noreply.github.com";
    extraConfig = {
      safe.directory = "/etc/nixos";
    };
  };

  programs.gpg.enable = true;

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
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

  # systemd.user.services.protonmail-bridge = {
  #   Unit = {
  #     Description = "ProtonMail Bridge";
  #   };
  #   Install = {
  #     WantedBy = [ "default.target" ];
  #   };
  #   Service = {
  #     ExecStart = "${pkgs.protonmail-bridge}/bin/protonmail-bridge --noninteractive";
  #   };
  # };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    ".bash_aliases".source = dotfiles/bash_aliases;
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/vasilysterekhov/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "vim";
    # make pfetch not count nix packages (slow)
    PF_FAST_PKG_COUNT = 1;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Let home-manager manage shell
  programs.bash.enable = true;
  programs.bash.bashrcExtra = ''
      . ~/.bash_aliases
      source "$(blesh-share)"/ble.sh
      pfetch
  '';

  # Similarly, let home-manager manage the xsession
  xsession.enable = true;
  
  # Unfree package exceptions
  nixpkgs.config.allowUnfreePredicate =
    let whitelist = map lib.getName (with pkgs; [
      aseprite
      vscode-extensions.github.copilot
      vscode-extensions.github.copilot-chat
    ]);
    in pkg: builtins.elem (lib.getName pkg) whitelist;

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    mutableExtensionsDir = false;
    extensions = (with pkgs.vscode-extensions; [
      eamodio.gitlens
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
    };
  };
}
