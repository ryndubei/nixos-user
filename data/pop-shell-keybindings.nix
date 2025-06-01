# https://github.com/NixOS/nixpkgs/issues/314969#issuecomment-2317070849
# pop-shell keybindings except workspace/monitor controls
{
  "org/gnome/desktop/wm/keybindings" = {
    close = [ "<Super>q" "<Alt>F4" ];
    minimize = [ "<Super>comma" ];
    toggle-maximized = [ "<Super>m" ];
    maximize = [ ];
    unmaximize = [ ];
  };

  "org/gnome/shell/keybindings" = {
    open-application-menu = [ ];
    toggle-message-tray = [ "<Super>v" ];
    toggle-overview = [ ];
  };

  "org/gnome/mutter/keybindings" = {
    toggle-tiled-left = [ ];
    toggle-tiled-right = [ ];
  };

  "org/gnome/mutter/wayland/keybindings" = { restore-shortcuts = [ ]; };

  "org/gnome/settings-daemon/plugins/media-keys" = {
    screensaver = [ "<Super>Escape" ];
    home = [ "<Super>f" ];
    www = [ "<Super>b" ];
    email = [ "<Super>e" ];
    rotate-video-lock-static = [ ];
    custom-keybindings = [
      "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/pop-shell-open-terminal/"
    ];
  };

  "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/pop-shell-open-terminal" =
    {
      name = "Open Terminal";
      command = "kgx";
      binding = "<Super>t";
    };

  "org/gnome/shell/extensions/pop-shell" = {
    toggle-tiling = [ "<Super>y" ];
    toggle-floating = [ "<Super>g" ];
    tile-enter = [ "<Super>Return" ];
    tile-accept = [ "Return" ];
    tile-reject = [ "Escape" ];
    toggle-stacking-global = [ "<Super>s" ];
    focus-left = [ "<Super>Left" "<Super>h" ];
    focus-down = [ "<Super>Down" "<Super>j" ];
    focus-up = [ "<Super>Up" "<Super>k" ];
    focus-right = [ "<Super>Right" "<Super>l" ];
  };
}
