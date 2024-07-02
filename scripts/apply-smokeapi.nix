{ pkgs, smokeapi, app-ids-names, steam-app-ids, lib, ... }:

let
  app-id-path-exe = pkgs.runCommandNoCC "app-id-path" { allowSubstitutes = false; } ''
    ${pkgs.ghc}/bin/ghc -o $out -O2 ${./AppIdPath.hs}
  '';
  app-ids = builtins.map (a: if builtins.typeOf a == "int" then a else steam-app-ids."${a}") app-ids-names;
  app-ids-string = builtins.concatStringsSep " " (map toString app-ids);
  script-init = ''
    set -euo pipefail
    export smokeapi64_dll=${smokeapi}/steam_api64.dll
    export smokeapi32_dll=${smokeapi}/steam_api.dll
    paths=$(${app-id-path-exe} ${app-ids-string})
  '';
in
pkgs.writeShellScriptBin "apply-smokeapi"
  (lib.concatLines [ script-init (builtins.readFile ./apply-smokeapi.sh) ])
