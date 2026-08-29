{ pkgs, ... }:

{
  home.packages = with pkgs; [
    cabal-install
    haskell-language-server
  ];

  programs.nixvim = {
    extraConfigLua = ''
      -- Use vendored highlighting query for haskell
      vim.treesitter.query.set('haskell', 'highlights', vim.fn.readblob('${./haskell-highlights.scm}'))
    '';

    plugins.haskell-tools = {
      enable = true;
      hlsPackage = null; # auto discover whatever HLS is in PATH
      enableTelescope = true;
    };

    files."ftplugin/haskell.lua" = {
      # Use vim's own indent because the haskell one works poorly
      localOpts = {
        indentexpr = "";
      };
    };

    # Recommended optional packages on https://github.com/mrcjkb/haskell-tools.nvim
    extraPackages = with pkgs.haskellPackages; [
      fast-tags
      hoogle
    ];
  };
}
