{ config, ... }:

{
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.nixvim = {
    enable = true;

    opts = {
      backspace = "indent,eol,start";
      syntax = "on";
      expandtab = true;
      shiftwidth = 2;
      softtabstop = -1;
      swapfile = true;
      dir = "/tmp";
      number = true;
      relativenumber = true;
    };

    colorschemes.ayu.enable = true;

    performance.byteCompileLua.enable = true;
    performance.combinePlugins.enable = true;

    # Fuzzy finder
    plugins.telescope.enable = true;
    plugins.web-devicons.enable = true; # for telescope

    # Jump to last position in file when reopened
    plugins.lastplace.enable = true;

    # Git integration
    plugins.fugitive.enable = true;

    # Indentation detection
    plugins.guess-indent.enable = true;

    # Improved wildmenu (command menu completion)
    plugins.wilder = {
      enable = true;
      settings = {
        modes = [ ":" ];
      };
      options = {
        # unsure whether this does anything, had to remove
        # "/" and "?" from modes
        use_python_remote_plugin = 0;
      };
    };

    # Default language server configurations
    plugins.lspconfig.enable = true;
    lsp.servers.nixd.enable = true;

    # Syntax highlighting
    plugins.treesitter = {
      enable = true;

      highlight.enable = true;
      indent.enable = true;
      folding.enable = true;

      grammarPackages = with config.programs.nixvim.plugins.treesitter.package.builtGrammars; [
        # common
        bash
        json
        make
        markdown
        toml
        xml
        yaml

        # uncommon
        fish

        # general purpose
        c
        cpp
        haskell
        javascript
        nix
        python
        typescript

        # nvim
        lua
        vim
        vimdoc
      ];
    };

  };
}
