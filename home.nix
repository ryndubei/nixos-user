{ config, pkgs, ... }:

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
    user.signingkey = "0x7DC7104ECC9E31EC";
    commit.gpgsign = true;
    tag.gpgSign = true;
    github.user = "ryndubei";
  };

  # Email
  home.packages = [ pkgs.protonmail-bridge ];

  programs.aerc.enable = true;
  # Required for configuring accounts via home-manager. Safe with passwordCommand.
  # (home-manager complains about this)
  programs.aerc.extraConfig = {
    general.unsafe-accounts-conf = true;
    filters = {
      "text/plain" = "colorize";
      "text/calendar" = "calendar";
      "message/delivery-status" = "colorize";
      "message/rfc822" = "colorize";
      "text/html" = "! html";
      ".headers" = "colorize";
    };
  };

  # using program instead of service because the mail client (e.g. aerc) can call mbsync by itself
  programs.mbsync.enable = true;
  programs.mbsync.package = pkgs.isync.override { withCyrusSaslXoauth2 = true; };

  programs.mu.enable = true;
  programs.msmtp.enable = true;

  # NOTE: custom module (services/protonmail-bridge.nix)
  custom.services.protonmail-bridge.enable = true;

  accounts.email.maildirBasePath = ".mail";
  accounts.email.accounts =
    let
      # Certificate found via protonmail-brige --cli -> cert export
      # Has to be manually placed here.
      bridgeCertificatesFile = "${config.home.homeDirectory}/.config/protonmail/bridge-v3/cert.pem";
      outlook = {
        imap = {
          authentication = "xoauth2";
          host = "outlook.office365.com";
          port = 993;
        };
        smtp = {
          authentication = "xoauth2";
          host = "smtp.office365.com";
          port = 587;
        };
        # exclude useless microslop folders
        mbsync.patterns = [
          "*"
          "!Calendar"
          "!Calendar/*"
          "!Contacts"
          "!Contacts/*"
          "!Journal"
          "!Journal/*"
          "!Tasks"
          "!Tasks/*"
          "!Notes"
          "!Notes/*"
          "!Conversation History"
          "!Conversation History/*"
        ];
      };
    in
    {
      personal = {
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
        mbsync.patterns = [
          "*"
          "!All Mail"
          "!All Mail/*"
        ];
        mbsync.create = "both";
        mbsync.expunge = "both";

        aerc.enable = true;
        mu.enable = true;
        msmtp.enable = true;
      };
      uoe_student = {
        address = "s2280425@ed.ac.uk";
        userName = "s2280425@ed.ac.uk";
        realName = "Vasily Sterekhov";
        inherit (outlook) imap smtp;
        passwordCommand = "pizauth show uoe_student";

        mbsync.enable = true;
        mbsync.create = "both";
        mbsync.expunge = "both";
        mbsync.patterns = outlook.mbsync.patterns;

        aerc.enable = true;
        mu.enable = true;
        msmtp.enable = true;
      };
      uoe_staff = {
        address = "vsterekh@ed.ac.uk";
        userName = "vsterekh@ed.ac.uk";
        realName = "Vasily Sterekhov";
        inherit (outlook) imap smtp;
        passwordCommand = "pizauth show uoe_staff";

        mbsync.enable = true;
        mbsync.create = "both";
        mbsync.expunge = "both";
        mbsync.patterns = outlook.mbsync.patterns;

        aerc.enable = true;
        mu.enable = true;
        msmtp.enable = true;
      };
    };

  services.pizauth.enable = true;
  services.pizauth.accounts =
    let
      authUri = "https://login.microsoftonline.com/common/oauth2/v2.0/authorize";
      tokenUri = "https://login.microsoftonline.com/common/oauth2/v2.0/token";
      scopes = [
        "https://outlook.office365.com/IMAP.AccessAsUser.All"
        "https://outlook.office365.com/SMTP.Send"
        "offline_access"
      ];
      # https://support.mozilla.org/en-US/kb/microsoft-oauth-authentication-and-thunderbird-202
      # pretend to be thunderbird
      clientId = "9e5f94bc-e8a4-4e73-b8be-63364c29d753";
    in
    {
      "uoe_student" = {
        inherit
          authUri
          tokenUri
          clientId
          scopes
          ;
        loginHint = "s2280425@ed.ac.uk";
      };
      "uoe_staff" = {
        inherit
          authUri
          tokenUri
          clientId
          scopes
          ;
        loginHint = "vsterekh@ed.ac.uk";
      };
    };
}
