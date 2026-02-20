{
  lib,
  pkgs,
  config,
  ...
}:
let
  modifier = config.xsession.windowManager.i3.config.modifier;
  homeDirectory = config.home.homeDirectory;
  datagripProjectsDirectory = "${homeDirectory}/datagrip-projects";
  nixDatagrip = "${config.byDb.paths.nixPrograms}/datagrip/datasources";
in
{
  home = {
    packages = [ (import ./jetbrains.nix { inherit lib pkgs; }).datagrip ];
    activation = {
      symlinkDatagripProfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p ${datagripProjectsDirectory}/Perso/.idea
        ln -sf ${nixDatagrip}/perso/dataSources.xml ${datagripProjectsDirectory}/Perso/.idea/dataSources.xml
        ln -sf ${nixDatagrip}/perso/dataSources.local.xml ${datagripProjectsDirectory}/Perso/.idea/dataSources.local.xml
        mkdir -p ${datagripProjectsDirectory}/Stockly/.idea
        ln -sf ${nixDatagrip}/stockly/dataSources.xml ${datagripProjectsDirectory}/Stockly/.idea/dataSources.xml
        ln -sf ${nixDatagrip}/stockly/dataSources.local.xml ${datagripProjectsDirectory}/Stockly/.idea/dataSources.local.xml
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
          ls -1 ${datagripProjectsDirectory} | \
          ${config.rofi.defaultCmd}
        )
        if [[ $project ]]; then
          datagrip ${datagripProjectsDirectory}/$project
        fi
      ''}/bin/open-datagrip-project";
    };
  };
}
