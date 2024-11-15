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
  home.packages = [ pkgs.slack ];
  xsession.windowManager.i3.config = {
    assigns = {
      "$ws4" = [ { class = "Slack"; } ];
    };
    keybindings = lib.mkOptionDefault { "${modifier}+Control+l" = "workspace $ws4; exec slack"; };
  };
}
