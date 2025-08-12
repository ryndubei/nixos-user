{ anti-ip, config, lib, ... }:

{
  services.flatpak.packages = [ "com.valvesoftware.Steam" ];

  services.flatpak.overrides = {
    "com.valvesoftware.Steam".Context = {
      filesystems = [
        "!xdg-music"
        "!xdg-pictures"
        "/mnt/hard_drive/data/${config.home.username}/Games_(slow)/Steam_Library"
        "${anti-ip.libstellarkey}:ro"
      ];
    };
    "com.valvesoftware.Steam".Environment = {
      # add LD_PRELOAD="$STELLARKEY_PATH:$LD_PRELOAD" %command% to launch options to use
      "STELLARKEY_PATH" = "${anti-ip.libstellarkey}/lib/libstellarkey.so";
    };
  };

  # Run apply-smokeapi on startup
  # TODO: move this to a Steam desktop file
  systemd.user.services.apply-smokeapi = let
    # The appids (ints)/names (strings) we are attempting to patch
    apps = [
      "Europa Universalis IV" # https://0xacab.org/stellarkey/stellarkey/-/issues/2
    ];
  in {
    Unit.Description = "Apply SmokeAPI";
    Install.WantedBy = [ "graphical-session.target" ];
    Service = {
      Type = "oneshot";
      ExecStart = "${anti-ip.apply-smokeapi apps}/bin/apply-smokeapi";
    };
  };

  # Run apply-smokeapi on home-manager activation as well
  home.activation.startApplySmokeapi =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run /run/current-system/sw/bin/systemctl start --user apply-smokeapi.service
    '';
}
