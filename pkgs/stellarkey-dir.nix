{ steam-app-ids, lib, runCommandNoCC }:

# Given a string 'str', filters the dlc set to only those containing
# 'str' in their name, and returns the result as a string of lines in the format
# 'appid = name;', written to a file DLC.txt in a directory in the Nix store.
str:
let
  dlcs = lib.attrsets.filterAttrs
    (name: appid: (builtins.match ".*${lib.escapeRegex str}.*" name != null))
    steam-app-ids.dlc.data;
  config = lib.strings.concatStrings (lib.attrsets.mapAttrsToList
    (name: appid: ''
      ${toString appid} = "${name}"
    '') dlcs);
in runCommandNoCC "stellarkey-dir" { } ''
  mkdir $out
  cp ${builtins.toFile "DLC.txt" config} $out/DLC.txt
''
