{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (config.byDb) modifier;
  inherit (config.byDb) ws;
in
{
  home.packages = [ pkgs.slack ];
  wayland.windowManager.sway.config = {
    assigns = {
      "\"${ws."4"}\"" = [ { class = "Slack"; } ];
    };
    keybindings = lib.mkOptionDefault {
      "${modifier}+Control+l" = "workspace \"${ws."4"}\"; exec slack";
    };
  };
}
