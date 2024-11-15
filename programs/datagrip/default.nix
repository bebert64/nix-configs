{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = {
    home = {
      packages = [ (import ./jetbrains.nix { inherit lib pkgs; }).datagrip ];
      activation = {
        symlinkDatagripProfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          ln -sf $HOME/${config.by-db.nixConfigsRepo}/programs/datagrip/Datagrip $HOME/
        '';
      };
    };

    xsession.windowManager.i3.config.assigns = {
      "$ws6" = [ { class = "jetbrains-datagrip"; } ];
    };
  };
}
