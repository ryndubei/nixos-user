{ pkgs, smokeapi, app-ids-names, steam-app-ids, ... }:

let
  app-id-path-exe = pkgs.runCommandNoCC "app-id-path" { allowSubstitutes = false; } ''
    ${pkgs.ghc}/bin/ghc -o $out -O2 ${./AppIdPath.hs}
  '';
  app-ids = builtins.map (a: if builtins.typeOf a == "int" then a else steam-app-ids."${a}") app-ids-names;
  app-ids-string = builtins.concatStringsSep " " (map toString app-ids);
in
pkgs.writeShellScriptBin "apply-smokeapi" ''
  set -euo pipefail

  export smokeapi64_dll=${smokeapi}/steam_api64.dll
  export smokeapi32_dll=${smokeapi}/steam_api.dll

  paths=$(${app-id-path-exe} ${app-ids-string})

  upd_32 () {
    cp --update=none steam_api.dll steam_api.dll_o
    cp $smokeapi32_dll steam_api.dll
  }
  upd_64 () {
    cp --update=none steam_api64.dll steam_api64.dll_o
    cp $smokeapi64_dll steam_api64.dll
  }
  export -f upd_32
  export -f upd_64

  IFS=$'\n'
  for path in $paths; do
    cd $path
    find -type f -name "steam_api.dll" -execdir bash -c upd_32 bash \;
    find -type f -name "steam_api64.dll" -execdir bash -c upd_64 bash \;
  done
''
