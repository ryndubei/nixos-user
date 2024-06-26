{
  description = "Home Manager configuration of vasilysterekhov";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.4.1";

    stellarkey-source.url = "gitlab:stellarkey/stellarkey?host=0xacab.org";
    stellarkey-source.flake = false;

    spotify-adblock-source.url = "github:abba23/spotify-adblock";
    spotify-adblock-source.flake = false;
  };

  outputs = { nixpkgs, home-manager, nix-flatpak, stellarkey-source, spotify-adblock-source, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      libstellarkey = pkgs.callPackage (import pkgs/stellarkey.nix) { src = stellarkey-source; };
      libspotifyadblock = pkgs.callPackage (import pkgs/spotify-adblock.nix) { src = spotify-adblock-source; };
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
        extraSpecialArgs = { inherit libstellarkey libspotifyadblock spotify-adblock-source; };
      };

      nixosModules = {
        home = import ./home.nix;
        desktop = import ./desktop.nix;
      };
    };
}
