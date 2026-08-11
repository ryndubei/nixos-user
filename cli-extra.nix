# Heavy packages and services that may not be wanted

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    android-tools
    cabal-install
    compiledb # to generate compile_commands.json for non-clang C projects
    clang-tools
    ffmpeg
    ghc
    haskell-language-server
    nix-output-monitor
    nixd
    pandoc
    python3
    sage
    scala_3
    steam-run-free # Fixes most library problems when running outside of Nix
    yt-dlp
  ];

  services.syncthing.enable = true;

  home.file.".haskeline".text = "editMode: Vi";
  home.file.".ghci".source = dotfiles/ghci;
}
