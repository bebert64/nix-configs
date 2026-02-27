{ pkgs }:
let
  inherit (pkgs) writeScriptBin;
  playerctl = "${pkgs.playerctl}/bin/playerctl --ignore-player=firefox,chromium";
in
{
  playerctlMove = "${writeScriptBin "playerctl-move" ''
    CURRENT_PLAYER=$(${playerctl} --list-all | head -n 1)

    case $CURRENT_PLAYER in
      "strawberry") ${playerctl} position $2$1;;
      *) ${playerctl} position $(expr $(${playerctl} position | cut -d . -f 1) $1 $2);;
    esac
  ''}/bin/playerctl-move";

  playerctlPlayPause = "${writeScriptBin "playerctl-play-pause" ''
    ${playerctl} play-pause
  ''}/bin/playerctl-play-pause";

  playerctlStop = "${writeScriptBin "playerctl-stop" ''
    ${playerctl} stop
  ''}/bin/playerctl-stop";

  playerctlStopAll = "${writeScriptBin "playerctl-stop-all" ''
    ${playerctl} -a stop
  ''}/bin/playerctl-stop-all";

  playerctlRestartOrPrevious = "${writeScriptBin "playerctl-restart-or-previous" ''
    CURRENT_PLAYER=$(${playerctl} --list-all | head -n 1)

    case $CURRENT_PLAYER in
      "strawberry")
        strawberry --restart-or-previous;;
      *)
        if (($(${playerctl} position | cut -d . -f 1) < 10)); then
          ${playerctl} previous;
        else
          ${playerctl} position 1;
        fi;;
    esac
  ''}/bin/playerctl-restart-or-previous";
}
