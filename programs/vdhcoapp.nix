# companion to VideoDownloadHelper browser add-on
{ pkgs, lib, ... }:
{
  config.home = {
    activation = {
      installVdhcoapp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${pkgs.vdhcoapp}/bin/vdhcoapp install
      '';
    };
  };
}
