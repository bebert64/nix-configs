{
  pkgs,
  config,
  lib,
  ...
}:
let
  modifier = config.byDb.modifier;
  ws = config.byDb.ws;
in
{
  home.packages = [ pkgs.slack ];
  wayland.windowManager.sway.config = {
    assigns = {
      "\"${ws."4"}\"" = [ { class = "Slack"; } ];
    };
    keybindings = lib.mkOptionDefault { "${modifier}+Control+l" = "workspace \"${ws."4"}\"; exec slack"; };
  };
}
