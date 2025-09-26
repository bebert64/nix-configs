# Terminal
{
  pkgs,
  config,
  lib,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  nixConfigsRepo = "${homeDir}/${config.by-db.nixConfigsRepo}";
in
{
  home = {
    packages = with pkgs; [
      mpc-qt
    ];
    activation = {
      symlinkMpcQtConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ln -sf ${nixConfigsRepo}/programs/mpc-qt/settings.json ${homeDir}/.config/mpc-qt/
      '';
    };
  };
  xsession.windowManager.i3.config = {
    assigns = {
      "$ws19" = [
        {
          class = "mpc-qt";
          instance = "lock1";
        }
      ];
      "$ws20" = [
        {
          class = "mpc-qt";
          instance = "lock2";
        }
      ];
    };
  };
}
