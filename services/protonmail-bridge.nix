{ config, lib, pkgs, ... }:

let cfg = config.services.protonmail-bridge;
in {
  # home-manager now has a built-in protonmai-bridge module,
  # but it is very basic
  options.custom.services.protonmail-bridge = {
    enable = lib.mkEnableOption "ProtonMail Bridge";

    package = lib.mkOption {
      description = "The ProtonMail Bridge package to use";
      defaultText = lib.literalExpression "protonmail-bridge-wrapper";
      example = lib.literalExpression "pkgs.protonmail-bridge";
      type = lib.types.package;
      default = pkgs.writeShellScriptBin "protonmail-bridge-wrapper" ''
        # Check if the user is logged in, fail to start if not
        set -euo pipefail

        fail () {
            echo "Must log in manually using protonmail-bridge --cli" >&2
            exit 1
        }

        coproc ${pkgs.protonmail-bridge}/bin/protonmail-bridge --cli --log-level panic

        # Send info command
        echo "info" >&"''${COPROC[1]}"

        # Get the 17th line of the output (skipping the ASCII art)
        output="$(sed '17q;d' <&"''${COPROC[0]}")"

        echo "Bridge says: $output" >&2

        if [[ "$output" =~ ^'Please login to '.*' to get email client configuration.'$ ]]; then
            fail
        elif [[ "$output" == 'No active accounts. Please add account to continue.' ]]; then
            fail
        fi

        kill "$COPROC_PID" || true

        exec ${pkgs.protonmail-bridge}/bin/protonmail-bridge "$@"
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.protonmail-bridge = {
      Unit.Description = "ProtonMail Bridge";
      Unit.After = [ "graphical-session.target" ];
      Install.WantedBy = [ "graphical-session.target" ];
      Service = {
        ExecStart =
          "${lib.getExe cfg.package} --noninteractive --log-level info";
        Restart = "always";
        TimeoutStartSec = 10;
        Type = "exec";

        # Sandboxing.
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateUsers = true;
        RestrictNamespaces = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service";
      };
    };
  };
}
