{
  description = "Home Manager configuration of vasilysterekhov";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.5.1";

    stellarkey-source.url = "gitlab:stellarkey/stellarkey?host=0xacab.org";
    stellarkey-source.flake = false;

    spotify-adblock-source.url = "github:abba23/spotify-adblock";
    spotify-adblock-source.flake = false;

    # TODO: compile this from source
    smokeapi-zip.url = "https://github.com/acidicoala/SmokeAPI/releases/download/v2.0.5/SmokeAPI-v2.0.5.zip";
    smokeapi-zip.type = "file";
    smokeapi-zip.flake = false;

    steamappidlist.url = "github:jsnli/SteamAppIDList";
    steamappidlist.flake = false;
  };

  outputs = { nixpkgs, home-manager, nix-flatpak, stellarkey-source, spotify-adblock-source, smokeapi-zip, steamappidlist, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      smokeapi = pkgs.callPackage (import pkgs/smokeapi.nix) { inherit smokeapi-zip; };
      steam-app-ids = builtins.listToAttrs
        (builtins.map ({ name, appid, ... }: { inherit name; value = appid; })
          (builtins.fromJSON (builtins.readFile "${steamappidlist}/data/games_appid.json")).apps
        );
      anti-ip = {
        libstellarkey = pkgs.callPackage (import pkgs/stellarkey.nix) { src = stellarkey-source; };

        inherit spotify-adblock-source;
        libspotifyadblock = pkgs.callPackage (import pkgs/spotify-adblock.nix) { src = spotify-adblock-source; };

        apply-smokeapi = app-ids-or-names: pkgs.callPackage (import scripts/apply-smokeapi.nix) { inherit smokeapi app-ids-or-names steam-app-ids; };
      };
    in
    {
      homeConfigurations."vasilysterekhov" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          ({ ... }: {
            # User-specific settings
            home.username = "vasilysterekhov";
            home.homeDirectory = "/home/vasilysterekhov";

            programs.git.userName = "ryndubei";
            programs.git.userEmail = "114586905+ryndubei@users.noreply.github.com";
          })
          ./home.nix
          ./desktop.nix
          nix-flatpak.homeManagerModules.nix-flatpak
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = { inherit anti-ip; };
      };

      nixosModules = {
        home = import ./home.nix;
        desktop = import ./desktop.nix;
      };
    };
}
