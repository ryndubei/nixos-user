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
      nix-output-monitor = p.nix-output-monitor.overrideAttrs rec {
        version = "0-unstable-2026-07-14";
        src = p.fetchFromGitHub {
          owner = "maralorn";
          repo = "nix-output-monitor";
          rev = "030658cd63512887c74652261079ca8bbb636c23";
          hash = "sha256-Ok5wLwYcQvM4u4zS1b7aP72sFH/bWlowWvBPvx+LPqs=";
        };
        propagatedBuildInputs = p.nix-output-monitor.propagatedBuildInputs or [ ] ++ [
          p.haskellPackages.fsnotify
          p.haskellPackages.doctest-parallel
        ];
        sourceRoot = "${src.name}/nix-output-monitor";
      };
    })
  ];
}
