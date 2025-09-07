{ inputs, ... }:

{
  nixpkgs.overlays = [
    (k: p:
      assert p ? frozenpkgs == false; {
        frozenpkgs = import inputs.nixpkgs-frozen { inherit (k) system; };
      })
    (k: p: {
      steam-app-ids = assert p ? steam-app-ids == false;
        k.callPackage ./pkgs/steam-app-ids.nix {
          inherit (inputs) steamappidlist;
        };
      stellarkey-dir = assert p ? stellarkey-dir == false;
        k.callPackage ./pkgs/stellarkey-dir.nix { };
    })
    (k: p: {
      libstellarkey = assert p ? libstellarkey == false;
        k.frozenpkgs.callPackage ./pkgs/stellarkey.nix { };
      libspotifyadblock = assert p ? libspotifyadblock == false;
        k.frozenpkgs.callPackage ./pkgs/spotify-adblock.nix { };
      apply-smokeapi = assert p ? apply-smokeapi == false;
        app-ids-or-names:
        k.frozenpkgs.callPackage ./scripts/apply-smokeapi.nix {
          inherit app-ids-or-names;
          inherit (k) steam-app-ids;
        };
    })
  ];
}
