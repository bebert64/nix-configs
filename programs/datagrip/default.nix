{ lib, pkgs, ... }:
{
  config.home = {
    packages = [
      (import ./jetbrains.nix { inherit lib pkgs; }).datagrip
    ];
    activation = {
      symlinkDatagripProfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ln -sf ${./Datagrip/DataGripProjects} $HOME
      '';
    };
  };
}
