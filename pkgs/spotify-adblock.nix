{ src, rustPlatform, ... }:

rustPlatform.buildRustPackage {
  inherit src;
  name = "spotify-adblock";
  cargoLock.lockFile = "${src}/Cargo.lock";
}
