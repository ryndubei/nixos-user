{
  config,
  pkgs,
  lib,
  ...
}:

let
  milou = pkgs.stdenv.mkDerivation {
    pname = "milou-nvim";
    version = "0-unstable-2026-05-13";
    src = pkgs.fetchFromForgejo {
      domain = "git.confusedcompiler.org";
      owner = "leana8959";
      repo = "milou";
      rev = "b02ca8d9b385c79a802b137c8c73157cdfc7ba3f";
      hash = "sha256-BYdERbb2wkBovTXl95PcKsdaBl2WDyv+nc/9LhENCNw=";
    };
    patches = [
      # delimiter colour already provided by rainbow-delimiters
      ./match-parens.patch
    ];
    installPhase = ''
      cp -r . $out
    '';
    meta.license = lib.licenses.mit;
  };
in
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

    extraPlugins = [ milou ]; # theme

    extraConfigLua = ''
      -- lsp-lines
      vim.diagnostic.config({ virtual_lines = { only_current_line = true } })
      -- milou
      require('milou').setup()
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
    # Matching colours on opening/closing brackets based on Treesitter
    plugins.rainbow-delimiters.enable = true;
    plugins.rainbow-delimiters.settings = {
      highlight = [
        # TODO use red for unmatched brackets somehow
        # "RainbowDelimiterRed"
        "RainbowDelimiterYellow"
        "RainbowDelimiterViolet"
        "RainbowDelimiterBlue"
        # "RainbowDelimiterOrange"
        # "RainbowDelimiterGreen"
        # "RainbowDelimiterCyan"
      ];
    };

    # Automatic brackets
    plugins.nvim-autopairs.enable = true;

    # Save sessions per project
    plugins.auto-session.enable = true;

  };
}
