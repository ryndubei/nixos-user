{config, pkgs, ...}:

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
  programs.git.settings = {
    user.name = "Vasily Sterekhov";
    user.email = "vasily.sterekhov@protonmail.com";
  };

  # Email
  home.packages = [ pkgs.protonmail-bridge ];

  programs.aerc.enable = true;
  programs.mbsync.enable = true; # using program instead of service because the mail client can call mbsync by itself

  # NOTE: custom module (services/protonmail-bridge.nix)
  custom.services.protonmail-bridge.enable = true;

  accounts.email.accounts = {
    personal =
      let
        # Certificate found via protonmail-brige --cli -> cert export
        # Has to be manually placed here.
        bridgeCertificatesFile = "${config.home.homeDirectory}/.config/protonmail/bridge-v3/cert.pem";
      in
      {
        address = "vasily.sterekhov@protonmail.com";
        userName = "vasily.sterekhov@protonmail.com";

        primary = true;

        # Password found via protonmail-bridge --cli -> info
        # Has to be manually stored using:
        # secret-tool store --label='ProtonMail Bridge local password' 'xdg:schema' 'org.gnome.keyring.Note' 'server' 'protonmail-bridge' 'username' 'vasily.sterekhov@protonmail.com'
        passwordCommand = "${pkgs.libsecret}/bin/secret-tool lookup 'xdg:schema' 'org.gnome.keyring.Note' 'server' 'protonmail-bridge' 'username' 'vasily.sterekhov@protonmail.com'";

        realName = "Vasily Sterekhov";

        imap = {
          tls.certificatesFile = bridgeCertificatesFile;
          tls.useStartTls = true;
          host = "127.0.0.1";
          port = 1143;
        };
        smtp = {
          tls.certificatesFile = bridgeCertificatesFile;
          tls.useStartTls = true;
          host = "127.0.0.1";
          port = 1025;
        };

        mbsync.enable = true;
        # exclude All Mail folder, as it will otherwise duplicate everything
        mbsync.patterns = ["*" "!All Mail" "!All Mail/*"];
        mbsync.create = "both";
        mbsync.expunge = "both";
      };
  };
}
