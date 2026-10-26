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
    (
      k: p:
      assert p ? unstable == false;
      {
        unstable = import inputs.nixpkgs-unstable {
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
      prismlauncher-unwrapped = p.prismlauncher-unwrapped.overrideAttrs (old: {
        version = "10.0.5";
        src = k.fetchFromGitHub {
          tag = "10.0.5";
          hash = "sha256-cQBOdF3HP4CFOSfWyVXGQBs42V/A4w6R2UwelQTE3dQ";
          owner = "PrismLauncher";
          repo = "PrismLauncher";
        };
        patches = (old.patches or [ ]) ++ [ ./patches/10.x-fuckmicrosoft.patch ];
      });
      prismlauncher = p.prismlauncher.override (old: {
        additionalPrograms = (old.additionalPrograms or [ ]) ++ [
          # To enable sandboxing for all instances by default, go to
          # Prism Launcher Settings -> Minecraft -> Custom Commands -> Wrapper Command
          # and enter prismlauncher-sandbox
          (k.writeShellApplication {
            name = "prismlauncher-sandbox";
            text = builtins.readFile ./scripts/prismlauncher-sandbox-instance.sh;
            runtimeInputs = [ k.bubblewrap ];
          })
        ];
      });
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
      };
    })
    (
      k: p:
      assert p ? boots == false;
      {
        boots = p.frozenpkgs.callPackage ./pkgs/boots.nix { };
      }
    )
  ];
}
