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
  home.packages = [ pkgs.slack ];
  wayland.windowManager.sway.config = {
    assigns = {
      "$ws4" = [ { class = "Slack"; } ];
    };
    keybindings = lib.mkOptionDefault { "${modifier}+Control+l" = "workspace $ws4; exec slack"; };
  };
}
