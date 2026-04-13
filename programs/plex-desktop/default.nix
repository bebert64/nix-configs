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
  home.packages = [ pkgs.plex-desktop ];
  wayland.windowManager.sway.config = {
    assigns = {
      "\"${ws."8"}\"" = [ { class = "Plex"; } ];
    };
    keybindings = lib.mkOptionDefault {
      "${modifier}+Control+p" = "workspace \"${ws."8"}\"; exec plex-desktop";
    };
  };
}
