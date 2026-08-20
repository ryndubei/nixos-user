{ pkgs, lib, ... }:

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
  programs.nixvim = {
    colorschemes.ayu.enable = true;
    colorschemes.ayu.luaConfig.pre = ''
      -- to use colorscheme's own colours in override
      local colors = require('ayu.colors')
      colors.generate() -- pass true to generate using mirage
    '';
    colorschemes.ayu.settings.overrides.__raw = ''
      {
        LineNr = { fg = colors.ui },
        -- using @type.definition for Haskell type signatures
        ['@type.definition.haskell'] = { fg = colors.func },
        -- colour haskell constructors, modules like in codium
        ['@module.haskell'] = { fg = colors.entity },
        ['@constructor.haskell'] = { fg = colors.regexp },
        -- unlike codium, also colour haskell record members as signatures
        -- NOTE: since the grammr cannot determine whether OverloadedRecordDot is
        -- enabled, this will lead to function composition without whitespace
        -- between the '.' to be wrongly coloured.
        ['@variable.member.haskell'] = { fg = colors.func },
        -- OverloadedLabels
        ['@label.haskell'] = { fg = colors.tag }
      }
    '';

    extraPlugins = [ milou ];

    # Use milou as light theme
    autoCmd = [
      {
        event = "OptionSet";
        pattern = "background";
        callback.__raw = ''
          function()
            if vim.o.background == 'light' then
              vim.cmd([[colorscheme milou]])
            else
              vim.cmd([[colorscheme ayu]])
            end
            vim.cmd("mode")
          end
        '';
      }
    ];

    extraConfigLua = ''
      if vim.o.background == 'light' then
        vim.cmd([[colorscheme milou]])
      end
    '';

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
  };
}
