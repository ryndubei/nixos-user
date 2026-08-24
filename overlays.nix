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
        version = "0-unstable-2026-08-11";
        src = p.fetchFromGitHub {
          owner = "maralorn";
          repo = "nix-output-monitor";
          rev = "e7c24c7576d5ab89957fe8ffe6b6077ff3934669";
          hash = "sha256-LhAG+vrrm/8c+SF8TKATMuTmm0vMxUApyA3vHiFmdsY=";
        };
        propagatedBuildInputs = p.nix-output-monitor.propagatedBuildInputs or [ ] ++ [
          p.haskellPackages.fsnotify
          p.haskellPackages.doctest-parallel
        ];
      };
    })
  ];
}
