# Terminal
{ pkgs, lib, ... }:
{
  config.home = {
    packages = [
      pkgs.tilix
    ];
    activation = {
      loadTilixTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${pkgs.dconf}/bin/dconf load /com/gexperts/Tilix/ < ${./tilix.dconf}
      '';
    };
  };
}
