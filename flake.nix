{
  description = "Home Manager configuration of vasilysterekhov";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    nixpkgs-frozen.url = "nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    steamappidlist.url = "github:jsnli/SteamAppIDList";
    steamappidlist.flake = false;
  };

  outputs = inputs@{ nixpkgs, home-manager, nix-flatpak, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
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
            ./steam.nix
            ./services/protonmail-bridge.nix
            ./overlays.nix
            nix-flatpak.homeManagerModules.nix-flatpak
          ];

          # Optionally use extraSpecialArgs
          # to pass through arguments to home.nix
          extraSpecialArgs = { inherit inputs; };
        };

      homeManagerModules = {
        cli-extra = import ./cli-extra.nix;
        cli = import ./cli.nix;
      };
    };
}
