# companion to VideoDownloadHelper browser add-on
{ pkgs, lib, ... }:
{
  home = {
    activation = {
      installVdhcoapp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${pkgs.vdhcoapp}/bin/vdhcoapp install
      '';
    };
  };
}
