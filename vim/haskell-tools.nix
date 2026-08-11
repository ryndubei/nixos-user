{ pkgs, ... }:

{
  home.packages = with pkgs; [
    cabal-install
    haskell-language-server
  ];

  programs.nixvim = {
    plugins.haskell-tools = {
      enable = true;
      hlsPackage = null; # auto discover whatever HLS is in PATH
      enableTelescope = true;
    };

    # Recommended optional packages on https://github.com/mrcjkb/haskell-tools.nvim
    extraPackages = with pkgs.haskellPackages; [
      fast-tags
      hoogle
    ];
  };
}
