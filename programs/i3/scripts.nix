{
  cfg,
  pkgs,
  lib,
}:
let
  inherit (cfg)
    minutes-before-lock
    minutes-from-lock-to-sleep
    setHeadphonesCommand
    setSpeakerCommand
    ;
  inherit (lib) makeBinPath;
  inherit (pkgs)
    coreutils
    playerctl
    pulseaudio
    strawberry
    writeScriptBin
    ;
in
{
  playerctl-move = "${writeScriptBin "playerctl-move" ''
    CURRENT_PLAYER=$(playerctl --list-all | head -n 1)

    case $CURRENT_PLAYER in
      "strawberry") playerctl position $2$1;;
      *) playerctl position $(expr $(playerctl position | cut -d . -f 1) $1 $2);;
    esac
  ''}/bin/playerctl-move";

  playerctl-restart-or-previous = "${writeScriptBin "playerctl-restart-or-previous" ''
    PATH=${
      makeBinPath [
        playerctl
        coreutils
        strawberry
      ]
    }

    CURRENT_PLAYER=$(playerctl --list-all | head -n 1)

    case $CURRENT_PLAYER in
      "strawberry")
        strawberry --restart-or-previous;;
      *)
        if (($(playerctl position | cut -d . -f 1) < 10)); then
          playerctl previous;
        else
          playerctl position 1;
        fi;;
    esac
  ''}/bin/playerctl-restart-or-previous";

  set-headphones = "${writeScriptBin "set-headphones" ''
    PATH=${makeBinPath [ pulseaudio ]}
    pactl ${setHeadphonesCommand}
  ''}/bin/set-headphones";

  set-speaker = "${writeScriptBin "set-speaker" ''
    PATH=${makeBinPath [ pulseaudio ]}
    pactl ${setSpeakerCommand}
  ''}/bin/set-speaker";

  lock-conky = "${writeScriptBin "lock-conky" ''
    SLEEP=false
    while getopts "s" opt; do
      case $opt in
        s) SLEEP=true;;
        \?) echo "Invalid option. To sleep, use -s";;
      esac
    done

    # Prepare screen
    pkill polybar || echo "polybar already killed"
    wk1=$(i3-msg -t get_workspaces | jq '.[] | select(.visible==true).name' | head -1)
    wk2=$(i3-msg -t get_workspaces | jq '.[] | select(.visible==true).name' | tail -1)
    i3-msg "workspace \" \"; workspace \"  \""

    # Sleep or prepare to sleep
    if [[ $SLEEP == true ]]; then
      systemctl suspend
    else
      pkill xidlehook || echo "xidlehook already killed"
      xidlehook --timer ${toString (minutes-from-lock-to-sleep * 60)} 'systemctl suspend' ' ' &
    fi

    # Lock
    alock -bg none -cursor blank

    # Revert to original config
    i3-msg workspace "$wk1"
    i3-msg workspace "$wk2"
    systemctl --user restart polybar
    pkill xidlehook || echo "xidlehook already killed"
    xidlehook --timer ${toString (minutes-before-lock * 60)} 'lock-conky' ' ' &
  ''}/bin/lock-conky";
}
