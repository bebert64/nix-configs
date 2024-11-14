{ pkgs, lib, ... }:
{
  config.home = {
    packages = [ pkgs.strawberry ];
    activation = {
      setupRadios = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # TODO
      '';
    };
  };
}
