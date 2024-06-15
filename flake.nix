{
  description = "Home Manager configuration of vasilysterekhov";

  inputs = {
    # Note: we take nixpkgs and home-manager from the system 
    # flake registry

    home-manager = {
      url = "home-manager";
      # I don't know why this is necessary: nixos-system already pins the
      # nixpkgs version for home-manager to the system version, which
      # is the one we use here. Nevertheless, without this line we get
      # two nixpkgs (24.05) versions in flake.lock.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations."vasilysterekhov" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}
