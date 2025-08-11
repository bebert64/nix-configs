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
  home.packages = [ pkgs.ferdium ];

  xsession.windowManager.i3.config = {
    assigns = {
      "$ws5" = [ { class = "ferdium"; } ];
    };
    keybindings = lib.mkOptionDefault { "${modifier}+Control+t" = "workspace $ws5; exec ferdium"; };
  };
}
