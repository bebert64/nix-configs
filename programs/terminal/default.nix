# Terminal
{
  pkgs,
  lib,
  config,
  ...
}:
let
  modifier = config.xsession.windowManager.i3.config.modifier;
in
{
  config = {
    home = {
      packages = [ pkgs.tilix ];
      activation = {
        loadTilixTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          ${pkgs.dconf}/bin/dconf load /com/gexperts/Tilix/ < ${./tilix.dconf}
        '';
      };
    };

    # tilix is not notification-aware so we need the no-startup-id
    xsession.windowManager.i3.config = {
      terminal = "--no-startup-id tilix";
      keybindings = {
        "${modifier}+Control+f" = "workspace $ws2; exec firefox";
        "${modifier}+Control+r" = "workspace $ws7; exec tilix -p Ranger -e ranger";
      };
    };
  };
}
