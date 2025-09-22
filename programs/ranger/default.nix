# Terminal
{
  pkgs,
  lib,
  config,
  ...
}:
let
  modifier = config.xsession.windowManager.i3.config.modifier;
  rofi = config.rofi.defaultCmd;
  sshr = "${pkgs.writeScriptBin "sshr" ''
    REMOTE=$1
    case $REMOTE in
      "cerberus") CMD="nix run \"nixpkgs#ranger\"";;
      *) CMD="ranger";;
    esac
    tilix -p Ranger -e "ssh $REMOTE -t ''${CMD}"
  ''}/bin/sshr";
  open-remote = "${pkgs.writeScriptBin "open-remote" ''
    selection=$(
      grep -P "^Host ([^*]+)$" $HOME/.ssh/config | \
      sed 's/Host //' | \
      tr ' ' '\n' | \
      sort -u | \
      grep -v "$(hostname)" | \
      ${rofi}
    )
    ${sshr} $selection
  ''}/bin/open-remote";
  homeDir = config.home.homeDirectory;
  nixConfigsRepo = "${homeDir}/${config.by-db.nixConfigsRepo}";
  rangerPluginsDir = "${homeDir}/.config/ranger/plugins";
in
{
  home = {
    packages = with pkgs; [
      ranger
      ffmpegthumbnailer # thumbnail for videos preview
      fontforge # thumbnail for fonts preview
      poppler_utils # thumbnail for pdf preview
      xclip # used to paste into global clipboard
    ];
    activation = {
      createRangerBookmarks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p ${homeDir}/.local/share/ranger/
        sed "s/\$USER/"$USER"/" ${./bookmarks} > ${homeDir}/.local/share/ranger/bookmarks
      '';

      symlinkRangerPlugins = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p ${rangerPluginsDir}/
        ln -sf ${nixConfigsRepo}/programs/configs/ranger/ranger-archives ${rangerPluginsDir}/
      '';
    };
    file = {
      ".config/ranger/rc.conf".source = ./rc.conf;
      ".config/ranger/rifle.conf".source = ./rifle.conf;
      ".config/ranger/scope.sh".source = ./scope.sh;
    };
  };

  xsession.windowManager.i3.config = {
    keybindings = lib.mkOptionDefault {
      "${modifier}+Control+r" = "workspace $ws7; exec tilix -p Ranger -e ranger";
      "${modifier}+Shift+r" = "workspace $ws7; exec ${open-remote}";
    };
  };
}
