{ rustPlatform, fetchFromGitHub, ... }:

rustPlatform.buildRustPackage rec {
  name = "spotify-adblock";
  src = fetchFromGitHub {
    owner = "abba23";
    repo = "spotify-adblock";
    rev = "8e0312d6085a6e4f9afeb7c2457517a75e8b8f9d";
    hash = "sha256-nwiX2wCZBKRTNPhmrurWQWISQdxgomdNwcIKG2kSQsE=";
  };
  cargoLock.lockFile = "${src}/Cargo.lock";
  allowSubstitutes = false;
}
