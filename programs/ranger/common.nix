{
  pkgs,
  lib,
  config,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  nixProgramsDir = config.byDb.paths.nixPrograms;
  rangerPluginsDir = "${homeDir}/.config/ranger/plugins";
in
{
  options.byDb.ranger.bookmarksFile = lib.mkOption {
    type = lib.types.path;
  };

  config.home = {
    packages = [ pkgs.ranger ];
    activation = {
      createRangerBookmarks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p ${homeDir}/.local/share/ranger/
        sed "s/\$USER/"$USER"/" ${config.byDb.ranger.bookmarksFile} > ${homeDir}/.local/share/ranger/bookmarks
      '';

      symlinkRangerPlugins = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p ${rangerPluginsDir}/
        ln -sfT ${nixProgramsDir}/ranger/ranger-archives ${rangerPluginsDir}/ranger-archives
      '';
    };
    file = {
      ".config/ranger/rc.conf".source = ./rc.conf;
      ".config/ranger/rifle.conf".source = ./rifle.conf;
      ".config/ranger/scope.sh".source = ./scope.sh;
    };
  };
}
