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
    colorschemes.ayu.luaConfig.pre = ''
      -- to use colorscheme's own colours in override
      local colors = require('ayu.colors')
      colors.generate() -- pass true to generate using mirage
    '';
    colorschemes.ayu.settings.overrides = {
      LineNr = {
        fg = {
          __raw = "colors.ui";
        };
      }; # make line numbers more readable
    };

    performance.byteCompileLua.enable = true;
    performance.combinePlugins.enable = true;

    # Status line
    plugins.lightline.enable = true;

    # Fuzzy finder
    plugins.telescope.enable = true;
    plugins.web-devicons.enable = true; # for telescope

    # Jump to last position in file when reopened
    plugins.lastplace.enable = true;

    # Git integration
    plugins.fugitive.enable = true;
    plugins.gitgutter.enable = true; # show changed lines

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

    plugins.lsp-lines.enable = true; # show lsp error (diagnostic) messages
    extraConfigLua = ''
      -- lsp-lines
      vim.diagnostic.config({ virtual_lines = { only_current_line = true } })
    '';
    keymaps = [
      {
        # Toggle lsp-lines
        key = "<Leader>l";
        action.__raw = "require('lsp_lines').toggle";
        options.unique = true;
      }
    ];

    # LSP code completions
    plugins.cmp.enable = true;
    plugins.cmp-nvim-lsp.enable = true;

    # LSP folding ranges
    plugins.nvim-ufo.enable = true;

    # Syntax highlighting
    plugins.treesitter = {
      enable = true;

      highlight.enable = true;
      indent.enable = true;

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
    # Matching colours on opening/closing brackets based on Treesitter
    # TODO use red for unmatched brackets somehow
    plugins.rainbow-delimiters.enable = true;

    # Automatic brackets
    plugins.autoclose.enable = true;

    # Save sessions per project
    plugins.auto-session.enable = true;

  };
}
