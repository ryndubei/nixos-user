{ inputs, ... }:

{
  nixpkgs.overlays = [
    (
      k: p:
      assert p ? frozenpkgs == false;
      {
        frozenpkgs = import inputs.nixpkgs-frozen {
          inherit (k.stdenv.hostPlatform) system;
        };
      }
    )
    (k: p: {
      steam-app-ids =
        assert p ? steam-app-ids == false;
        k.callPackage ./pkgs/steam-app-ids.nix {
          inherit (inputs) steamappidlist;
        };
    })
    (k: p: {
      libstellarkey =
        assert p ? libstellarkey == false;
        k.frozenpkgs.callPackage ./pkgs/stellarkey.nix { };
      libspotifyadblock =
        assert p ? libspotifyadblock == false;
        k.frozenpkgs.callPackage ./pkgs/spotify-adblock.nix { };
      apply-smokeapi =
        assert p ? apply-smokeapi == false;
        app-ids-or-names:
        k.frozenpkgs.callPackage ./scripts/apply-smokeapi.nix {
          inherit app-ids-or-names;
          inherit (k) steam-app-ids;
        };
    })
    (k: p: {
      nix-output-monitor = p.nix-output-monitor.overrideAttrs {
        version = "unstable-2026-06-12-83c1716";
        src = p.fetchFromGitHub {
          owner = "maralorn";
          repo = "nix-output-monitor";
          rev = "83c171617f3b5654e50ff0b90f1b2e544a322770";
          hash = "sha256-dReBf1ugLBtyj8pdn1I55cB04zLmbxKZQfjrm6+YoSs=";
        };
        propagatedBuildInputs = p.nix-output-monitor.propagatedBuildInputs or [ ] ++ [
          p.haskellPackages.fsnotify
        ];
      };
    })
  ];
}
