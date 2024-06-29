{ stdenv, src, ... }:

stdenv.mkDerivation {
  inherit src;
  name = "libstellarkey";
  buildPhase = "make libstellarkey.so";
  installPhase = ''
    mkdir -p $out/lib
    cp libstellarkey.so $out/lib
  '';
}
