{ pkgs, config, ... }:
let
  modifier = config.xsession.windowManager.i3.config.modifier;
in
{
  home.packages = [ pkgs.gnome.gnome-calculator ];
  xsession.windowManager.i3.config.keybindings = {
    # Maps to the + key on the numpad
    "${modifier}+Control+KP_Add" = "exec gnome-calculator";
  };
}
