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
    rev = "5f2e0898bd31ce475303d38fac48c45b127b31d5";
    hash = "sha256-Jbg04xb2MdumInHRnJ2sdoRwpRS7icSx+4ff92O/C9A=";
  };

  cargoHash = "sha256-l4M9VFCx7wUI6zRKVdk252Kcaftk+vw9Fo7QAlFCp2s=";
})
