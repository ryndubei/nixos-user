{
  programs.nixvim = {
    lsp.servers.clangd.enable = true;
    plugins.clangd-extensions.enable = true;
  };
}
