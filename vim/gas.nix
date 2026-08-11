{ pkgs, ... }:

{
  programs.nixvim = {

    extraPlugins = with pkgs.vimPlugins; [
      # Syntax highlighting for GNU as with AT&T syntax
      # because treesitter is not good with GNU as
      vim-gas
    ];

    lsp.servers.asm_lsp = {
      enable = true;
      config.filetypes = [ "gas" ];
    };
    # Assume all *.s files use GNU as
    autoCmd = [
      {
        command = "setfiletype gas";
        event = [
          "BufRead"
          "BufNewFile"
        ];
        pattern = [ "*.s" ];
      }
    ];
  };
}
