{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bat
    fishPlugins.hydro
    nixfmt-classic
    ripgrep
    tree
  ];

  programs.zoxide.enable = true;

  programs.fzf.enable = true;

  programs.git = {
    enable = true;
    extraConfig = { safe.directory = [ "/etc/nixos" "/etc/nixos/.git" ]; };
  };

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
  programs.fish.shellAbbrs.cd = "z";
  # Aliases that make sense in all shells
  home.shellAliases.cat = "bat -pp";
  # Commands that should only be run in interactive shells
  programs.fish.interactiveShellInit = ''
    # Use fish when calling 'nix shell' or 'nix develop'
    ${pkgs.nix-your-shell}/bin/nix-your-shell fish | source

    # Set up hydro theme
    set -g hydro_color_pwd green
    set -g hydro_color_error brred
    set -g hydro_color_duration brblue

    # Show pfetch summary
    ${pkgs.pfetch-rs}/bin/pfetch
  '';
}
