# Terminal
{ pkgs, lib, ... }:
{
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
  };
}
