{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bat
    deploy-rs
    fishPlugins.hydro
    git-crypt
    nixfmt-classic
    ripgrep
    sops
    tree
  ];

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
      set shiftwidth=4
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
    extraConfig = { safe.directory = [ "/etc/nixos" "/etc/nixos/.git" ]; };
  };

  programs.gpg.enable = true;

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
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
  # home.sessionVariables = { };

  # Let home-manager manage shell
  programs.bash.enable = true;
  programs.bash = {
    # When initialising bash, launch fish unless the parent process is already fish
    initExtra = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
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
    # produce hie AST and nothing more
    ghc-dump-hie = "ghc -fwrite-ide-info -fno-code -fforce-recomp -ddump-hie";
  };
  programs.fish.functions = {
    # we assume all extra substituters are just for development flakes, and not
    # worth querying for regular system updates
    rebuild-user =
      "home-manager $argv[1] --option substituters https://cache.nixos.org $argv[2..]";
    rebuild-system =
      "sudo nixos-rebuild $argv[1] --flake $argv[2]#$argv[3] --option substituters https://cache.nixos.org $argv[4..]";

    ghc-view-hie = "ghc-dump-hie $argv | ${pkgs.bat}/bin/bat --language log";

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
    # Use fish when calling 'nix shell' or 'nix develop'
    ${pkgs.nix-your-shell}/bin/nix-your-shell fish | source

    # Set up hydro theme
    set -g hydro_color_pwd green
    set -g hydro_color_error brred
    set -g hydro_color_duration brblue

    # Enable fish vi mode
    fish_vi_key_bindings

    # Show pfetch summary
    ${pkgs.pfetch-rs}/bin/pfetch
  '';
}
