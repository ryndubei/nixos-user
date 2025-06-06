# Heavy packages and services that may not be wanted

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    cabal-install
    clang-tools
    ffmpeg
    ghc
    pandoc
    (python3.withPackages (p: [ p.numpy p.pandas ]))
    sage
    scala_3
    yt-dlp
  ];

  services.syncthing.enable = true;

  home.file.".haskeline".text = "editMode: Vi";
}
