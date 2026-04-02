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
  home.packages = [ pkgs.plex-desktop ];
  wayland.windowManager.sway.config = {
    assigns = {
      "$ws8" = [ { class = "Plex"; } ];
    };
    keybindings = lib.mkOptionDefault {
      "${modifier}+Control+p" = "workspace $ws8; exec plex-desktop";
    };
  };
}
