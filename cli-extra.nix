# Heavy packages and services that may not be wanted

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    android-tools
    cabal-install
    clang-tools
    ffmpeg
    ghc
    pandoc
    (python3.withPackages (p: [ p.numpy p.pandas ]))
    sage
    scala_3
    steam-run-free # Fixes most library problems when running outside of Nix
    yt-dlp
  ];

  services.syncthing.enable = true;

  home.file.".haskeline".text = "editMode: Vi";
  home.file.".ghci".source = dotfiles/ghci;
}
