# smokeapi: the extracted smokeapi zip
# app-ids-names: list of app ids (ints) or names (strings)
# steam-app-ids: attrset mapping names to app ids

# Assumes a Flatpak installation of Steam.

# Returns a package containing a shell script to find and patch all
# steam_api.dll and steam_api64.dll files belonging to the specified
# appids.
{ pkgs, app-ids-or-names, lib, steam-app-ids }:

let
  smokeapi = pkgs.callPackage ../pkgs/smokeapi.nix { };
  app-id-path-exe =
    pkgs.runCommandNoCC "app-id-path" { allowSubstitutes = false; } ''
      ${pkgs.ghc}/bin/ghc -o $out -O2 ${./AppIdPath.hs}
    '';
  # 'name' is only to make the logs more human-readable
  app-ids-and-names =
    builtins.map (steam-app-ids.games.normalise) app-ids-or-names;
  app-ids-string = builtins.concatStringsSep " " (map lib.escapeShellArg
    (builtins.concatMap ({ appid, name }: [ (toString appid) name ])
      app-ids-and-names));
  libraryfolders-path =
    "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/libraryfolders.vdf";
  script-init = ''
    set -euo pipefail
    export smokeapi64_dll=${smokeapi}/steam_api64.dll
    export smokeapi32_dll=${smokeapi}/steam_api.dll
    libraryfolders="${libraryfolders-path}"
    if [ ! -f $libraryfolders ]; then
      echo 'libraryfolders.vdf not found, nothing to do' >&2
      exit 0
    fi
    paths=$(${app-id-path-exe} $libraryfolders ${app-ids-string})
  '';
in pkgs.writeShellScriptBin "apply-smokeapi"
(lib.concatLines [ script-init (builtins.readFile ./apply-smokeapi.sh) ])
