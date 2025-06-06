{
  description = "Home Manager configuration of vasilysterekhov";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    nixpkgs-frozen.url = "nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    stellarkey-source.url = "gitlab:stellarkey/stellarkey?host=0xacab.org";
    stellarkey-source.flake = false;

    spotify-adblock-source.url = "github:abba23/spotify-adblock";
    spotify-adblock-source.flake = false;

    # TODO: compile this from source
    smokeapi-zip.url =
      "https://github.com/acidicoala/SmokeAPI/releases/download/v2.0.5/SmokeAPI-v2.0.5.zip";
    smokeapi-zip.type = "file";
    smokeapi-zip.flake = false;

    steamappidlist.url = "github:jsnli/SteamAppIDList";
    steamappidlist.flake = false;
  };

  outputs = { nixpkgs, nixpkgs-frozen, home-manager, nix-flatpak
    , stellarkey-source, spotify-adblock-source, smokeapi-zip, steamappidlist
    , ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-frozen = nixpkgs-frozen.legacyPackages.${system};

      steam-app-ids = builtins.listToAttrs (builtins.map
        ({ name, appid, ... }: {
          inherit name;
          value = appid;
        }) (builtins.fromJSON
          (builtins.readFile "${steamappidlist}/data/games_appid.json")).apps);
      anti-ip = {
        # don't want to rebuild these on every e.g. new compiler release, so we use a fixed nixpkgs instance
        libstellarkey = pkgs-frozen.callPackage (import pkgs/stellarkey.nix) {
          src = stellarkey-source;
        };

        inherit spotify-adblock-source;
        libspotifyadblock =
          pkgs-frozen.callPackage (import pkgs/spotify-adblock.nix) {
            src = spotify-adblock-source;
          };

        apply-smokeapi = app-ids-or-names:
          let
            smokeapi = pkgs-frozen.callPackage (import pkgs/smokeapi.nix) {
              inherit smokeapi-zip;
            };
          in pkgs-frozen.callPackage (import scripts/apply-smokeapi.nix) {
            inherit smokeapi app-ids-or-names steam-app-ids;
          };
      };
    in {
      homeConfigurations."vasilysterekhov" =
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          # Specify your home configuration modules here, for example,
          # the path to your home.nix.
          modules = [
            ./home.nix
            ./cli.nix
            ./cli-extra.nix
            ./desktop.nix
            nix-flatpak.homeManagerModules.nix-flatpak
          ];

          # Optionally use extraSpecialArgs
          # to pass through arguments to home.nix
          extraSpecialArgs = { inherit anti-ip; };
        };

      homeManagerModules = {
        full = {
          imports = [ ./cli.nix ./home.nix ./desktop.nix ./cli-extra.nix ];
        };
        home = { imports = [ ./cli.nix ./home.nix ./cli-extra.nix ]; };
        cli-extra = import ./cli-extra.nix;
        cli = import ./cli.nix;
      };
    };
}
