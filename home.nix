{ pkgs, ... }:

{
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
    # agda
    bat
    blesh
    cryfs
    deploy-rs
    devenv
    gcc
    ghc
    git-crypt
    gocryptfs
    nixpkgs-fmt
    pfetch
    ripgrep
    tree
    yt-dlp
  ]);

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraConfig = ''
      set nocompatible
      set backspace=indent,eol,start
      syntax on
      set relativenumber
      set expandtab
      set tabstop=4
      set swapfile
      set dir=/tmp
      set number
      set mouse=
    '';
    extraLuaConfig = ''
      require'nvim-treesitter.configs'.setup {
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
      }
      require('lspconfig')['hls'].setup{
        filetypes = { 'haskell', 'lhaskell', 'cabal' },
      }
    '';
    plugins = with pkgs.vimPlugins; [
      vim-lastplace
      (nvim-treesitter.withPlugins (p: [ p.haskell p.nix ]))
      nvim-lspconfig
    ];
  };

  programs.zoxide.enable = true;

  programs.fzf.enable = true;

  programs.git = {
    enable = true;
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
    # make pfetch not count nix packages (slow)
    PF_FAST_PKG_COUNT = 1;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Let home-manager manage shell
  programs.bash.enable = true;
  # Commands that should only be run in interactive shells
  programs.bash.initExtra = ''
    . ~/.bash_aliases
    source "$(blesh-share)"/ble.sh
    set -o vi
    pfetch
  '';
}
