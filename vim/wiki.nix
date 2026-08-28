{
  programs.nixvim = {
    plugins.vimwiki.enable = true;
    plugins.vimwiki.settings = {
      list = [
        {
          ext = "md";
          path = "~/Documents/Notes";
          syntax = "markdown";
        }
      ];

      # Restrict vimwiki to only the paths in the list
      global_ext = 0;
      ext2syntax = [ ];
    };
    plugins.treesitter.luaConfig.post = ''
      vim.treesitter.language.register('markdown', { 'vimwiki' })
    '';
  };
}
