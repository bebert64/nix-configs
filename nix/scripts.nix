{ host-specific, pkgs, lib, ... }:
[
  (pkgs.writeScriptBin "mnas" ''
    #!/usr/bin/env bash
    set -euo pipefail

    IP=192.168.1.3
    NAME=NasLaFouillouse

    sudo mkdir -p /mnt/NAS

    if [[ $(ls /mnt/NAS) ]]; then
      echo "NAS seems to already be mounted"
      exit 0
    fi

    if ! ping -c1 $IP &> /dev/null; then
      echo "No machine responding at ''${IP}"
      exit 0
    fi

    if [[ $(curl -s ''${IP}:5000 | grep ''${NAME}) ]]; then
      sudo mount ''${IP}:/volume1/NAS /mnt/NAS
      echo "mounted ''${NAME} successfully"
    else
      echo "The machine at ''${IP} seems to not be ''${NAME}"
    fi 
  '')
  (pkgs.writeScriptBin "umnas" ''
    #!/usr/bin/env bash
    set -euo pipefail

    sudo umount /mnt/NAS
  '')

  (pkgs.writeScriptBin "psg" ''
    #!/usr/bin/env bash
    set -euo pipefail

    ps aux | grep $1 | grep -v psg | grep -v grep
  '')

  (pkgs.writeScriptBin "run" ''
    #!/usr/bin/env bash
    set -euxo pipefail

    nix run "nixpkgs#$1" -- "''${@:2}"
  '')

  (pkgs.writeScriptBin "sshr" ''
    #!/usr/bin/env bash
    set -euo pipefail

    REMOTE=$1

    case $REMOTE in
      "cerberus") CMD="nix run \"nixpkgs#ranger\"";;
      *) CMD="ranger";;
    esac

    tilix -p Ranger -e "ssh ''$1 -t ''${CMD}"
  '')

  (pkgs.writeScriptBin "sync-wallpapers" ''
    #!/usr/bin/env bash
    set -euxo pipefail

    mnas
    rsync -avh --exclude "Fond pour téléphone" $HOME/mnt/NAS/Wallpapers/ ~/wallpapers
    rsync -avh ~/wallpapers/ $HOME/mnt/NAS/Wallpapers
  '')

  (pkgs.writeScriptBin "is-music-playing" ''
    #!/usr/bin/env bash
    set -euxo pipefail

    TITLE="$(playerctl metadata title 2>&1)"
    if [[ "$TITLE" == *"No player could handle this command"* || "$TITLE" == *"No players found"* ]];then
            echo false;
    else
          echo true;
    fi;
  '')

  (pkgs.writeScriptBin "player-ctl-move" ''
    #!/usr/bin/env bash
    set -euxo pipefail

    CURRENT_PLAYER=$(playerctl --list-all | head -n 1)

    case $CURRENT_PLAYER in
      "strawberry") playerctl position $2$1;;
      *) playerctl position $(expr $(playerctl position | cut -d . -f 1) $1 $2);;
    esac

  '')

  (pkgs.writeScriptBin "player-ctl-restart-or-previous" ''
    #!/usr/bin/env bash
    set -euxo pipefail

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
  '')


  # (pkgs.writeScriptBin "playerctl-polybar" ''
  #   #!/usr/bin/bash
  #   set -euo pipefail

  #   PATH=${lib.makeBinPath [ pkgs.playerctl ]}

  #   status=$(playerctl status 2> /dev/null)
  #   title=$(playerctl metadata xesam:title 2> /dev/null)
  #   artist=$(playerctl metadata xesam:artist 2> /dev/null)
  #   note=
  #   previous=
  #   next=
  #   play=
  #   pause=
  #   stop=

  #   button_previous="%{A1:player-ctl-restart-or-previous:}  $previous  %{A}"
  #   button_next="%{A1:playerctl next:}  $next  %{A}"
  #   button_play="%{A1:playerctl play:}  $play  %{A}"
  #   button_pause="%{A1:playerctl pause:}  $pause  %{A}"
  #   button_stop="%{A1:playerctl -a stop:}  $stop  %{A}"

  #   if [[ $artist = "" ]]; then
  #       title_display=$title
  #   else
  #       title_display="$artist - $title"
  #   fi

  #   if [[ $status == "Playing" ]]; then
  #       button_status=$button_pause
  #   else
  #       button_status=$button_play
  #   fi

  #   command_bar="$button_previous$button_stop$button_status$button_next"

  #   echo "$note   $title_display   $command_bar"
  # '')

  (pkgs.writeScriptBin "launch_radios" ''
    #!/usr/bin/env bash
    set -euxo pipefail

    play_radio() {
      strawberry --play-playlist Radios
      strawberry --play-track $track
    }

    MENU="$(echo -n 'FIP|Jazz Radio|Radio Nova|Oui Fm|Classic FM|Chillhop Radio|Classical Piano Music' | rofi -no-config -no-lazy-grab -sep "|" -dmenu -i -p 'radio' \
      -theme $HOME/.config/rofi/theme/styles.rasi)"
    case "$MENU" in
      FIP) track=0 && play_radio ;;
      "Jazz Radio") track=1 && play_radio ;;
      "Radio Nova") track=2 && play_radio ;;
      "Oui Fm") track=3 && play_radio ;;
      "Classic FM") track=4 && play_radio ;;
      "Chillhop Radio") i3-msg "workspace 10:; exec firefox -new-window https://www.youtube.com/watch\?v\=5yx6BWlEVcY" ;;
      "Classical Piano Music") i3-msg "workspace 10:; exec firefox -new-window https://www.youtube.com/watch\?v\=tSlOlKRuudU" ;;
    esac
  '')

  (pkgs.writeScriptBin "lock-conky" ''
    #!/usr/bin/env bash
    set -euxo pipefail

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
      xidlehook --timer ${
        toString (host-specific.minutes-from-lock-to-sleep * 60)
      } 'systemctl suspend' ' ' &
    fi

    # Lock
    alock -bg none -cursor blank

    # Revert to original config
    i3-msg workspace "$wk1"
    i3-msg workspace "$wk2"
    $HOME/.config/polybar/launch.sh
    pkill xidlehook || echo "xidlehook already killed"
    xidlehook --timer ${toString (host-specific.minutes-before-lock * 60)} 'lock-conky' ' ' &
  '')
]
