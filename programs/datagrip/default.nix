{
  lib,
  pkgs,
  config,
  ...
}:
let
  modifier = config.xsession.windowManager.i3.config.modifier;
  paths = config.byDb.paths;
  datagripProjectsDir = "${paths.home}/datagrip-projects";
  nixDatagrip = "${paths.nixPrograms}/datagrip/datasources";
in
{
  home = {
    packages = [ (import ./jetbrains.nix { inherit lib pkgs; }).datagrip ];
    activation = {
      symlinkDatagripProfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p ${datagripProjectsDir}/Perso/.idea
        ln -sf ${nixDatagrip}/perso/dataSources.xml ${datagripProjectsDir}/Perso/.idea/dataSources.xml
        ln -sf ${nixDatagrip}/perso/dataSources.local.xml ${datagripProjectsDir}/Perso/.idea/dataSources.local.xml
        mkdir -p ${datagripProjectsDir}/Stockly/.idea
        ln -sf ${nixDatagrip}/stockly/dataSources.xml ${datagripProjectsDir}/Stockly/.idea/dataSources.xml
        ln -sf ${nixDatagrip}/stockly/dataSources.local.xml ${datagripProjectsDir}/Stockly/.idea/dataSources.local.xml
      '';
    };
  };

  xsession.windowManager.i3.config = {
    assigns = {
      "$ws6" = [ { class = "jetbrains-datagrip"; } ];
    };
    keybindings = lib.mkOptionDefault {
      "${modifier}+Control+d" = "workspace $ws6; exec ${pkgs.writeScriptBin "open-datagrip-project" ''
        project=$(
          ls -1 ${datagripProjectsDir} | \
          ${config.rofi.defaultCmd}
        )
        if [[ $project ]]; then
          datagrip ${datagripProjectsDir}/$project
        fi
      ''}/bin/open-datagrip-project";
    };
  };
}
