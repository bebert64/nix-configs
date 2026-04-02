{
  pkgs,
  config,
  lib,
  ...
}:
let
  modifier = config.byDb.modifier;
in
{
  home.packages = [ pkgs.ferdium ];

  wayland.windowManager.sway.config = {
    assigns = {
      "$ws5" = [
        { class = "ferdium"; }
        { class = "Ferdium"; }
      ];
    };
    keybindings = lib.mkOptionDefault { "${modifier}+Control+t" = "workspace $ws5; exec ferdium"; };
  };
}
