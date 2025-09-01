{ inputs, steam-app-ids, ... }:

{
  nixpkgs.overlays = [
    (k: p:
      assert p ? frozenpkgs == false; {
        frozenpkgs = import inputs.nixpkgs-frozen { inherit (k) system; };
      })
    (k: p: {
      libstellarkey = assert p ? libstellarkey == false;
        k.frozenpkgs.callPackage ./pkgs/stellarkey.nix { };
      libspotifyadblock = assert p ? libspotifyadblock == false;
        k.frozenpkgs.callPackage ./pkgs/spotify-adblock.nix { };
      apply-smokeapi = assert p ? apply-smokeapi == false;
        app-ids-or-names:
        k.frozenpkgs.callPackage ./scripts/apply-smokeapi.nix {
          inherit steam-app-ids app-ids-or-names;
        };
    })
  ];
}
