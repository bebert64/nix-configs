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
  home.packages = [ pkgs.chromium ];

  wayland.windowManager.sway.config = {
    keybindings = lib.mkOptionDefault {
      "${modifier}+Control+c" = "workspace $ws2; exec chromium --profile-directory=Default";
    };
    assigns = {
      "$ws2" = [ { class = "chromium-browser"; } ];
    };
  };
}
