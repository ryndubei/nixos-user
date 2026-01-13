{ pkgs, config, lib, ... }:

{
  services.flatpak.packages = [ "com.valvesoftware.Steam" ];

  services.flatpak.overrides = {
    "com.valvesoftware.Steam".Context = {
      filesystems = [
        "!xdg-music"
        "!xdg-pictures"
        "/mnt/hard_drive/data/${config.home.username}/Games_(slow)/Steam_Library"
        "${pkgs.libstellarkey}:ro"
        # https://github.com/WiVRn/WiVRn
        # (assumed in system config)
        "xdg-run/wivrn:ro"
        "xdg-state/wivrn:ro"
        "xdg-config/openxr:ro"
        "xdg-config/openvr:ro"
        # wivrn path in nix store is determined by the system config, so must
        # give access to the entire store
        "/nix/store:ro"
      ];
    };
    "com.valvesoftware.Steam".Environment = {
      # add LD_PRELOAD="$STELLARKEY_PATH:$LD_PRELOAD" %command% to launch options to use
      "STELLARKEY_PATH" = "${pkgs.libstellarkey}/lib/libstellarkey.so";
    };
  };

  # Run apply-smokeapi on startup
  # TODO: move this to a Steam desktop file
  systemd.user.services.apply-smokeapi = let
    # The appids (ints)/names (strings) we are attempting to patch
    apps = [ "Europa Universalis IV" "Stellaris" "Hearts of Iron IV" "Crusader Kings II" "Imperator: Rome" ];
  in {
    Unit.Description = "Apply SmokeAPI";
    Install.WantedBy = [ "graphical-session.target" ];
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.apply-smokeapi apps}/bin/apply-smokeapi";
    };
  };

  # Run apply-smokeapi on home-manager activation as well
  home.activation.startApplySmokeapi =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run /run/current-system/sw/bin/systemctl start --user apply-smokeapi.service
    '';

  home.activation.steamOpenxrSymlink =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p ~/.var/app/com.valvesoftware.Steam/.config/openxr/1
      run ln -sf ~/.config/openxr/1 ~/.var/app/com.valvesoftware.Steam/.config/openxr/1
    '';
}
