{
  description = "Home Manager configuration of vasilysterekhov";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    nixpkgs-frozen.url = "nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs"; # follow current nixpkgs, against nixvim's recommendation
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    steamappidlist.url = "github:jsnli/SteamAppIDList";
    steamappidlist.flake = false;
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      nix-flatpak,
      nixvim,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations."vasilysterekhov" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./home.nix
          ./cli.nix
          ./cli-extra.nix
          ./desktop.nix
          ./steam.nix
          ./services/protonmail-bridge.nix
          ./overlays.nix
          ./vim/base.nix
          ./vim/haskell-tools.nix
          ./vim/gas.nix
          ./vim/langmap.nix
          ./vim/nix.nix
          ./vim/theme.nix
          ./vim/web.nix
          ./vim/wiki.nix
          nix-flatpak.homeManagerModules.nix-flatpak
          nixvim.homeModules.nixvim
        ];

        extraSpecialArgs = { inherit inputs; };
      };

      homeManagerModules = {
        cli-extra = import ./cli-extra.nix;
        cli = import ./cli.nix;
      };
      checks.${system}.homeConfigurationBuilds =
        self.outputs.homeConfigurations."vasilysterekhov".activationPackage.out;
    };
}
