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
  home.packages = [ pkgs.plex-desktop ];
  xsession.windowManager.i3.config = {
    assigns = {
      "$ws8" = [ { class = "Plex"; } ];
    };
    keybindings = lib.mkOptionDefault {
      "${modifier}+Control+p" = "workspace $ws8; exec plex-desktop";
    };
  };
}
