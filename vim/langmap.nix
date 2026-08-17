{
  programs.nixvim = {
    # Russian keybindings
    plugins.langmapper.enable = true;
    plugins.langmapper.callSetup = false; # call manually before all other plugins

    extraConfigLuaPre = ''
      local function escape(str)
        local escape_chars = [[;,."|\]]
        return vim.fn.escape(str, escape_chars)
      end

      local en = [[`qwertyuiop[]asdfghjkl;'zxcvbnm]]
      local ru = [[ёйцукенгшщзхъфывапролджэячсмить]]
      local en_shift = [[~QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>]]
      local ru_shift = [[ËЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ]]

      vim.opt.langmap = vim.fn.join({
        escape(ru_shift) .. ';' .. escape(en_shift),
        escape(ru) .. ';' .. escape(en),
      }, ',')

      require('langmapper').setup({ hack_keymap = true })
    '';

    extraConfigLuaPost = ''
      require('langmapper').automapping({buffer = false})
    '';
  };
}
