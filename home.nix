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
    cabal-install
    deploy-rs
    devenv
    fishPlugins.hydro
    ghc
    git-crypt
    nixpkgs-fmt
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
    '';
    plugins = with pkgs.vimPlugins; [
      vim-lastplace
      (nvim-treesitter.withPlugins (p: [ p.haskell p.nix p.vimdoc ]))
    ];
  };

  programs.zoxide.enable = true;

  programs.fzf.enable = true;

  programs.git = {
    enable = true;
    extraConfig = {
      safe.directory = [ "/etc/nixos" "/etc/nixos/.git" ];
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
    # 1. initially set INTERACTIVE_SHELL to "fish"
    # 2. when 'bash' is first run as an interactive shell,
    #    this makes it run fish
    # 3. fish sets a function override for 'bash' that sets
    #    INTERACTIVE_SHELL to "bash" before running bash
    # This makes `nix shell` run in 'fish' without costing
    # us `bash -c`
    INTERACTIVE_SHELL = "fish";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Let home-manager manage shell
  programs.bash.enable = true;
  # Switch to fish if INTERACTIVE_SHELL is set to fish
  programs.bash = {
    initExtra = ''
      if [[ $INTERACTIVE_SHELL != "bash" ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec $INTERACTIVE_SHELL $LOGIN_OPTION
      fi
    '';
  };
  programs.fish.enable = true;
  programs.fish.shellAbbrs = {
    cd = "z";
    cdh = "cd $HOME/projects/HASKELL";
  };
  # Aliases that make sense in all shells
  home.shellAliases = {
    flatpak = "flatpak --user";
    logoutall = "loginctl terminate-user $(whoami)";
    cat = "bat -pp";
  };
  programs.fish.shellAliases = {
    pull-system = "fish -c 'cd /etc/nixos && sudo git fetch && sudo git pull'";
    pull-user = "fish -c 'cd ~/.config/home-manager && git fetch && git pull'";
    update-user = "pull-user && rebuild-user switch";
    update-system = "pull-system && rebuild-system switch /etc/nixos";
  };
  programs.fish.functions = {
    # we assume all extra substituters are just for development flakes, and not
    # worth querying for regular system updates
    rebuild-user = "home-manager $argv[1] --option substituters https://cache.nixos.org $argv[2..]";
    rebuild-system = "sudo nixos-rebuild $argv[1] --flake $argv[2]#$argv[3] --option substituters https://cache.nixos.org $argv[4..]";

    bash = "begin; set -lx INTERACTIVE_SHELL \"bash\"; command bash $argv; end";
    # Fix unsightly background on vi mode indicator in hydro
    fish_mode_prompt = ''
      switch $fish_bind_mode
        case default
          set_color --italics --bold red
          echo ' N '
        case insert
          set_color --italics --bold green
          echo ' I '
        case replace replace_one
          set_color --italics --bold green
          echo ' R '
        case visual
          set_color --italics --bold brmagenta
          echo ' V '
        case '*'
          set_color --italics --bold red
          echo $fish_bind_mode
      end
      set_color normal
    '';
  };
  # Commands that should only be run in interactive shells
  programs.fish.interactiveShellInit = ''
    set -g hydro_color_pwd green
    set -g hydro_color_duration brblue
    fish_vi_key_bindings
    ${pkgs.pfetch-rs}/bin/pfetch
  '';
}
