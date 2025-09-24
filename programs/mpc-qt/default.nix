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
    # file = {
    #   ".config/mpc-qt/settings.json".source = ./settings.json;
    # };
    activation = {
      symlinkMpcQtConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ln -sf ${nixConfigsRepo}/programs/mpc-qt/settings.json ${homeDir}/.config/mpc-qt/
      '';
    };
  };
  xsession.windowManager.i3.config = {
    assigns = {
      "$ws11" = [
        {
          class = "mpc-qt";
          instance = "Lock1";
        }
      ];
      "$ws12" = [
        {
          class = "mpc-qt";
          instance = "Lock2";
        }
      ];
    };
  };
}
