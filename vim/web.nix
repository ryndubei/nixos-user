{
  programs.nixvim = {
    lsp.servers.eslint.enable = true;
    lsp.servers.html.enable = true;
    lsp.servers.cssls.enable = true;
    lsp.servers.jsonls.enable = true;
    lsp.servers.ts_ls.enable = true;
  };
}
