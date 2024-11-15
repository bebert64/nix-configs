# Terminal
{
  pkgs,
  lib,
  config,
  ...
}:
let
  modifier = config.xsession.windowManager.i3.config.modifier;
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
        mkdir -p $HOME/.local/share/ranger/
        sed "s/\$USER/"$USER"/" ${./bookmarks} > $HOME/.local/share/ranger/bookmarks
      '';
    };
    file = {
      ".config/ranger/rc.conf".source = ./rc.conf;
      ".config/ranger/scope.sh".source = ./scope.sh;
    };
  };

  xsession.windowManager.i3.config = {
    keybindings = {
      "${modifier}+Control+r" = "workspace $ws7; exec tilix -p Ranger -e ranger";
    };
  };
}
