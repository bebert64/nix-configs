# Terminal
{ pkgs, lib, ... }:
{
  config.home = {
    packages = with pkgs; [
      ranger
      ffmpegthumbnailer # thumbnail for videos preview
      fontforge # thumbnail for fonts preview
      poppler_utils # thumbnail for pdf preview
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
}
