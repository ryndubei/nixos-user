{ inputs, steam-app-ids, ... }:

{
  nixpkgs.overlays = [
    (k: p:
      assert p ? frozenpkgs == false; {
        frozenpkgs = import inputs.nixpkgs-frozen { inherit (p) system; };
      })
    (k: p: {
      libstellarkey = assert p ? libstellarkey == false;
        p.frozenpkgs.callPackage ./pkgs/stellarkey.nix { };
      libspotifyadblock = assert p ? libspotifyadblock == false;
        p.frozenpkgs.callPackage ./pkgs/spotify-adblock.nix { };
      apply-smokeapi = assert p ? apply-smokeapi == false;
        app-ids-or-names:
        p.frozenpkgs.callPackage ./scripts/apply-smokeapi.nix {
          inherit steam-app-ids app-ids-or-names;
        };
    })
  ];
}
