# Heavy packages and services that may not be wanted

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    android-tools
    cabal-install
    clang-tools
    ffmpeg
    ghc
    haskell-language-server
    nix-output-monitor
    nixd
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

  programs.neovim.initLua = ''
    vim.lsp.enable('hls')
    vim.lsp.enable('nixd')
  '';
  programs.neovim.extraPackages = with pkgs; [
    haskellPackages.fast-tags
    haskellPackages.hoogle
    haskellPackages.haskell-debug-adapter
    haskellPackages.ghci-dap
  ];
  programs.neovim.plugins = with pkgs.vimPlugins; [
    nvim-dap
    nvim-lspconfig
    telescope-nvim
    {
      plugin = haskell-tools-nvim;
      runtime."after/ftplugin/haskell.lua".text = ''
        local ht = require('haskell-tools')
        local bufnr = vim.api.nvim_get_current_buf()
        local opts = { noremap = true, silent = true, buffer = bufnr, }
        -- haskell-language-server relies heavily on codeLenses,
        -- so auto-refresh (see advanced configuration) is enabled by default
        vim.keymap.set('n', '<space>cl', vim.lsp.codelens.run, opts)
        -- Hoogle search for the type signature of the definition under the cursor
        vim.keymap.set('n', '<space>hs', ht.hoogle.hoogle_signature, opts)
        -- Evaluate all code snippets
        vim.keymap.set('n', '<space>ea', ht.lsp.buf_eval_all, opts)
        -- Toggle a GHCi repl for the current package
        vim.keymap.set('n', '<leader>rr', ht.repl.toggle, opts)
        -- Toggle a GHCi repl for the current buffer
        vim.keymap.set('n', '<leader>rf', function()
          ht.repl.toggle(vim.api.nvim_buf_get_name(0))
        end, opts)
        vim.keymap.set('n', '<leader>rq', ht.repl.quit, opts)
      '';
    }
  ];
}
