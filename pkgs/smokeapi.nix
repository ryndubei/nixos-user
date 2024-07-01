{ pkgs, smokeapi-zip, ... }:

pkgs.runCommandNoCC "smokeapi" { allowSubstitutes = false; } ''
  mkdir $out
  ${pkgs.unzip}/bin/unzip ${smokeapi-zip} -d $out
''
