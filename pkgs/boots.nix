{
  lib,
  rustPlatform,
  fetchFromGitea,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "boots";
  version = lib.substring 0 8 finalAttrs.src.rev;

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "leana8959";
    repo = "boots";
    rev = "3db57645025a3c1f491afc3fb99003a9c658ebcf";
    hash = "sha256-ilYbGTm+vJ4wjsyWm6MgEcPm5vtMxmej7SciZh0iitk=";
  };

  cargoHash = "sha256-fmzpoZiPzoIwwJE7X5jO6wVW4KBvMhDZ1D14G3pHAII=";
})
