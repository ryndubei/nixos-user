{ pkgs, smokeapi }:

pkgs.writeShellScriptBin "apply-smokeapi" ''
  smokeapi_dll=${smokeapi}/steam_api64.dll
''
