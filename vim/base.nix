{
  config,
  pkgs,
  ...
}:

{
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.nixvim = {
    enable = true;

    nixpkgs.pkgs = pkgs; # suppress warning from following nixpkgs in flake.nix

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
      winborder = "rounded";
      foldlevel = 3; # arbitrary number that seems to be usually good
      indentkeys = "!^F,!0<Tab>,o,O";
    };

    performance.byteCompileLua.enable = true;
    # combinePlugins fails with lualine + ayu
    # performance.combinePlugins.enable = true;

    # Colour previews
    plugins.colorizer.enable = true;

    # Status line
    plugins.lualine.enable = true;

    # Fuzzy finder
    plugins.telescope.enable = true;
    plugins.web-devicons.enable = true; # for telescope

    # Jump to last position in file when reopened
    plugins.lastplace.enable = true;

    # Git integration
    plugins.fugitive.enable = true;
    plugins.gitsigns.enable = true; # show changed lines
    plugins.gitblame.enable = true; # constant inline blame

    # Indentation detection
    plugins.guess-indent.enable = true;

    # Default language server configurations
    plugins.lspconfig.enable = true;

    extraConfigLua = ''
      -- Show diagnostic messages between source lines
      vim.diagnostic.config({ virtual_lines = { current_line = true } })

      -- experimental new cmdline and message UI
      require('vim._core.ui2').enable()
    '';

    # Code completions
    plugins.blink-cmp.enable = true;
    plugins.blink-cmp.settings = {
      cmdline.completion.menu.auto_show = true;
      completion.menu.draw = {
        columns.__raw = ''
          { { "label", gap = 1 }, { "kind_icon" } }
        '';
        components.label = {
          text.__raw = ''
            function(ctx)
              return require('colorful-menu').blink_components_text(ctx)
            end
          '';
          highlight.__raw = ''
            function(ctx)
              return require('colorful-menu').blink_components_highlight(ctx)
            end
          '';
        };
      };
      completion.documentation.auto_show = true;
    };
    plugins.colorful-menu.enable = true; # Syntax highlighting for completions
    plugins.blink-ripgrep.enable = true;

    # LSP folding ranges
    plugins.origami.enable = true;
    plugins.origami.settings = {
      foldKeymaps.setup = false; # the new keybindings are annoying more often than not
    };

    # Syntax highlighting
    plugins.treesitter = {
      enable = true;

      highlight.enable = true;

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
        ledger
        scheme

        # general purpose
        c
        cpp
        haskell
        nix
        python

        # web
        html
        javascript
        typescript

        # nvim
        lua
        vim
        vimdoc
      ];
    };
    plugins.treesitter.luaConfig.post = ''
      vim.opt_global.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    '';

    # Automatic opening/closing brackets with rainbow highlighting
    plugins.blink-pairs.enable = true;
    plugins.blink-pairs.settings = {
      highlights.groups = [
        "BlinkPairsYellow"
        "BlinkPairsPurple"
        "BlinkPairsBlue"
      ];
    };
    plugins.blink-pairs.luaConfig.post = ''
      -- https://github.com/saghen/blink.pairs/issues/121
      vim.api.nvim_set_hl(0, 'BlinkPairsOrange', { ctermfg = 15, fg = '#d65d0e', default = true })
      vim.api.nvim_set_hl(0, 'BlinkPairsPurple', { ctermfg = 13, fg = '#b16286', default = true })
      vim.api.nvim_set_hl(0, 'BlinkPairsBlue', { ctermfg = 12, fg = '#458588', default = true })
      vim.api.nvim_set_hl(0, 'BlinkPairsUnmatched', { ctermfg = 9, fg = '#ff007c', default = true })
      vim.api.nvim_set_hl(0, 'BlinkPairsMatchParen', { link = 'MatchParen', default = true })

      -- the orange is indistinguishable from the purple when night light is on
      vim.api.nvim_set_hl(0, 'BlinkPairsYellow', { ctermfg = 15, fg = '#d79921', default = true })
    '';

    autoCmd = [
      {
        event = "ColorScheme";
        callback.__raw = ''
          -- rainbow highlighting will no longer work after changing colorscheme
          -- without this
          function()
            vim.api.nvim_set_hl(0, 'BlinkPairsOrange', { ctermfg = 15, fg = '#d65d0e', default = true })
            vim.api.nvim_set_hl(0, 'BlinkPairsPurple', { ctermfg = 13, fg = '#b16286', default = true })
            vim.api.nvim_set_hl(0, 'BlinkPairsBlue', { ctermfg = 12, fg = '#458588', default = true })
            vim.api.nvim_set_hl(0, 'BlinkPairsUnmatched', { ctermfg = 9, fg = '#ff007c', default = true })
            vim.api.nvim_set_hl(0, 'BlinkPairsMatchParen', { link = 'MatchParen', default = true })
            vim.api.nvim_set_hl(0, 'BlinkPairsYellow', { ctermfg = 15, fg = '#d79921', default = true })
          end
        '';
      }
    ];

    # Save sessions per project
    plugins.auto-session.enable = true;
    plugins.auto-session.settings = {
      suppressed_dirs.__raw = ''
        { vim.fn.getenv("HOME") }
      '';
    };
  };
}
