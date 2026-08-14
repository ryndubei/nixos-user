{
  programs.nixvim = {
    lsp.servers.nixd.enable = true;

    # Formatter plugin
    plugins.conform-nvim.enable = true;
    plugins.conform-nvim.settings = {
      formatters_by_ft = {
        nix = [ "nixfmt" ];
      };
    };

    extraConfigLua = ''
      -- Use conform's formatexpr for gq formatting
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    '';

    # Automatically format *.nix files on save
    # (to save without formatting, use :noa w)
    autoCmd = [
      {
        event = "BufWritePre";
        pattern = "*.nix";
        callback = {
          __raw = ''
            function(args)
              require('conform').format({bufnr = args.buf})
            end
          '';
        };
      }
    ];
  };
}
