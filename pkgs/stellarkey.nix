{ stdenv, fetchFromGitLab, ... }:

stdenv.mkDerivation {
  name = "libstellarkey";
  src = fetchFromGitLab {
    domain = "0xacab.org";
    owner = "stellarkey";
    repo = "stellarkey";
    rev = "717fa2d53db3e7e0019dfad19748ceb7137699b";
    hash = "sha256-NLSRi/M16bLGA2bs1HANUHOR5JnrGCMudWQBTAVJGpM=";
  };
  buildPhase = "make libstellarkey.so";
  installPhase = ''
    mkdir -p $out/lib
    cp libstellarkey.so $out/lib
  '';
  allowSubstitutes = false;
}
