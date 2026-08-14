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
      so = 10;
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
    plugins.gitsigns.enable = true; # show changed lines

    # Indentation detection
    plugins.guess-indent.enable = true;

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

    # Code completions
    plugins.cmp.enable = true;
    plugins.cmp-nvim-lsp.enable = true; # completions from the language server
    plugins.cmp-buffer.enable = true; # words in the buffer
    plugins.cmp-path.enable = true; # file paths
    plugins.cmp.settings.sources = [
      { name = "nvim_lsp"; }
      { name = "path"; }
      { name = "buffer"; }
    ];
    plugins.cmp.cmdline =
      let
        search_cfg = {
          mapping = {
            __raw = "cmp.mapping.preset.cmdline()";
          };
          sources = [
            {
              name = "buffer";
            }
          ];
        };
      in
      {
        "?" = search_cfg;
        "/" = search_cfg;
        ":" = {
          mapping = {
            __raw = "cmp.mapping.preset.cmdline()";
          };
          sources = [
            { name = "buffer"; }
            {
              name = "cmdline";
              options = {
                ignore_cmds = [
                  "Man"
                  "!"
                ];
              };
            }
          ];
        };
      };

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
    plugins.nvim-autopairs.enable = true;

    # Save sessions per project
    plugins.auto-session.enable = true;

  };
}
