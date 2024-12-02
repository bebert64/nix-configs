{
  pkgs,
  config,
  lib,
  ...
}:
let
  modifier = config.xsession.windowManager.i3.config.modifier;
in
{
  home.packages = [ pkgs.gnome-calculator ];
  xsession.windowManager.i3.config.keybindings = lib.mkOptionDefault {
    # Maps to the + key on the numpad
    "${modifier}+Control+KP_Add" = "exec gnome-calculator";
  };
}
