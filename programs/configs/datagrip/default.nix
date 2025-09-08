{
  lib,
  pkgs,
  config,
  ...
}:
let
  modifier = config.xsession.windowManager.i3.config.modifier;
  homeDir = config.home.homeDirectory;
  nixConfigsRepo = "${homeDir}/${config.by-db.nixConfigsRepo}";
in
{
  home = {
    packages = [ (import ./jetbrains.nix { inherit lib pkgs; }).datagrip ];
    activation = {
      symlinkDatagripProfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p ${homeDir}/datagrip-projects/perso/.idea
        ln -sf ${nixConfigsRepo}/programs/configs/datagrip/datasources/perso/dataSources.xml ${homeDir}/datagrip-projects/perso/.idea/dataSources.xml
        ln -sf ${nixConfigsRepo}/programs/configs/datagrip/datasources/perso/dataSources.local.xml ${homeDir}/datagrip-projects/perso/.idea/dataSources.local.xml
        mkdir -p ${homeDir}/datagrip-projects/Stockly/.idea
        ln -sf ${nixConfigsRepo}/programs/configs/datagrip/datasources/Stockly/dataSources.xml ${homeDir}/datagrip-projects/Stockly/.idea/dataSources.xml
        ln -sf ${nixConfigsRepo}/programs/configs/datagrip/datasources/Stockly/dataSources.local.xml ${homeDir}/datagrip-projects/Stockly/.idea/dataSources.local.xml
      '';
    };
  };

  xsession.windowManager.i3.config = {
    assigns = {
      "$ws6" = [ { class = "jetbrains-datagrip"; } ];
    };
    keybindings = lib.mkOptionDefault { "${modifier}+Control+d" = "workspace $ws6; exec datagrip"; };
  };
}
