{ stdenv, pkgs, smokeapi, app-ids, ... }:

let
  app-id-path-exe = stdenv.mkDerivation {
    src = ./.;
    name = "app-id-path";
    allowSubstitutes = false;
    buildInputs = [ pkgs.ghc ];
    buildPhase = "ghc -o app-id-path -O2 AppIdPath.hs";
    installPhase = "cp app-id-path $out";
  };
  app-ids-string = builtins.concatStringsSep " " (map toString app-ids);
in
pkgs.writeShellScriptBin "apply-smokeapi" ''
  smokeapi64_dll=${smokeapi}/steam_api64.dll
  smokeapi32_dll=${smokeapi}/steam_api.dll
  selected_appid_paths=$(${app-id-path-exe} ${app-ids-string})
  upd_32() {
    cp --update=none steam_api.dll steam_api.dll_o
    cp $smokeapi32_dll steam_api.dll
  }
  upd_64() {
    cp --update=none steam_api64.dll steam_api64.dll_o
    cp $smokeapi64_dll steam_api64.dll
  }
  for path in $selected_appid_paths; do
    cd $path
    find -type f -name "steam_api.dll" -execdir upd_32 \;
    find -type f -name "steam_api64.dll" -execdir upd_64 \;
  done
''
