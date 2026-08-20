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
    plugins.origami.enable = true;
    plugins.origami.settings = {
      foldKeymaps.setup = false; # the new keybindings are annoying more often than not
    };

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
        ledger
        scheme

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

    # Automatic brackets
    plugins.nvim-autopairs.enable = true;

    # Save sessions per project
    plugins.auto-session.enable = true;
    plugins.auto-session.settings = {
      suppressed_dirs.__raw = ''
        { vim.fn.getenv("HOME") }
      '';
    };
  };
}
