{
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # Automatically remove old home-manager configuration generations
  services.home-manager.autoExpire.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # User-specific settings
  home.username = "vasilysterekhov";
  home.homeDirectory = "/home/vasilysterekhov";
  programs.git.userName = "ryndubei";
  programs.git.userEmail = "114586905+ryndubei@users.noreply.github.com";
}
