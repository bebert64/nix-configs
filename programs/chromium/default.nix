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
  home.packages = [ pkgs.chromium ];

  xsession.windowManager.i3.config = {
    keybindings = lib.mkOptionDefault {
      "${modifier}+Control+c" = "workspace $ws2; exec chromium --profile-directory=Default";
    };
    assigns = {
      "$ws2" = [ { class = "chromium-browser"; } ];
    };
  };
}
