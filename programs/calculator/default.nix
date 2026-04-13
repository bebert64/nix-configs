{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (config.byDb) modifier;
in
{
  home.packages = [ pkgs.gnome-calculator ];
  wayland.windowManager.sway.config.keybindings = lib.mkOptionDefault {
    # Maps to the + key on the numpad
    "${modifier}+Control+KP_Add" = "exec gnome-calculator";
  };
}
