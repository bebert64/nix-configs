host-specifics: { pkgs, ...}:

[
  (pkgs.writeScriptBin "run" ''
    #!/usr/bin/env bash
    set -euxo pipefail

    nix-shell -p "$1" --command "''${1##*.} ''${*:2}"
  '')

  (pkgs.writeScriptBin "mount-NAS" ''
    #!/usr/bin/env bash
    set -euxo pipefail

    mount nas.capucina.house:/volume1/NAS
  '')

  (pkgs.writeScriptBin "sshr" ''
    #!/usr/bin/env bash
    set -euxo pipefail

    tilix -p Ranger -e "ssh ''${1##*.}"
  '')

  (pkgs.writeScriptBin "mount-Ipad" ''
    #!/usr/bin/env bash
    set -euxo pipefail
    
    ifuse --documents jp.tatsumi-sys.sidebooks $HOME/mnt/Ipad/SideBooks
    ifuse --documents com.mike-ferenduros.Chunky-Comic-Reader $HOME/mnt/Ipad/Chunky
    ifuse --documents com.wayudaorerk.mangastormall $HOME/mnt/Ipad/MangaStorm
  '')

  (pkgs.writeScriptBin "umount-Ipad" ''
    #!/usr/bin/env bash
    set -euxo pipefail

    fusermount -u $HOME/mnt/Ipad/SideBooks
    fusermount -u $HOME/mnt/Ipad/Chunky
    fusermount -u $HOME/mnt/Ipad/MangaStorm
  '')

  (pkgs.writeScriptBin "move-to-Ipad" ''
    #!/usr/bin/env bash
    set -euxo pipefail

    for n in $(seq 1 $#); do
      echo $1
      mkdir zip
      zip "zip/$1.zip" "$1"/*
      rsync --progress "zip/$1.zip" /home/romain/mnt/Ipad/Chunky
      rsync --progress "$1" /home/romain/mnt/Ipad/Chunky
      shift
    done
  '')

  (pkgs.writeScriptBin "available-size-Ipad" ''
    #!/usr/bin/env bash
    set -euxo pipefail

    df $HOME/mnt/Ipad-SideBooks | grep ifuse | tr -s ' ' | cut -d ' ' -f4m
  '')

  (pkgs.writeScriptBin "sync-wallpapers" ''
    #!/usr/bin/env bash
    set -euxo pipefail

    mount-NAS
    rsync -avh --exclude "Fond pour téléphone" $HOME/mnt/NAS/Wallpapers/ ~/wallpapers
    rsync -avh ~/wallpapers/ $HOME/mnt/NAS/Wallpapers
  '')

  (pkgs.writeScriptBin "open-code" ''
    #!/usr/bin/env bash
    set -euxo pipefail

    relative_path=$(pwd | cut -d'/' -f4-)
    code --folder-uri=vscode-remote://ssh-remote+charybdis/home/romain/$relative_path
  '')

  (pkgs.writeScriptBin "is-music-playing" ''
    #!/usr/bin/env bash
    set -euxo pipefail

    TITLE="$(playerctl -p strawberry metadata title 2>&1)"
    if [[ "$TITLE" == *"No player could handle this command"* || "$TITLE" == *"No players found"* ]];then
            echo false;
    else
          echo true;
    fi;
  '')

  (pkgs.writeScriptBin "playerctl_polybar" ''
    #!/usr/bin/env bash
    set -euxo pipefail

    touch /home/romain/.config/.radio_title
    
    playerctlstatus=$(playerctl -p strawberry status 2> /dev/null)
    title=$(playerctl -p strawberry metadata xesam:title 2> /dev/null)
    artist=$(playerctl -p strawberry metadata xesam:artist 2> /dev/null)
    radio_title=`cat /home/romain/.config/.radio_title`
    note=
    previous=
    next=
    play=
    pause=
    stop=

    button_previous="%{A1:strawberry --restart-or-previous:}  $previous  %{A}"
    button_next="%{A1:playerctl -p strawberry next:}  $next  %{A}"
    button_play="%{A1:playerctl -p strawberry play:}  $play  %{A}"
    button_pause="%{A1:playerctl -p strawberry pause:}  $pause  %{A}"
    button_stop="%{A1:playerctl -p strawberry stop:}  $stop  %{A}"

    if [[ $title = http* ]]; then
        if [ -z "$radio_title" ]; then
            title_display="Radio youtube"
        else
            title_display=$radio_title
        fi
    elif [[ $artist = "" ]]; then
        title_display=$title
    else
        title_display="$artist - $title"
    fi

    if [[ $playerctlstatus == "Playing" ]]; then
        button_status=$button_pause
    else
        button_status=$button_play
    fi

    command_bar="$button_previous$button_stop$button_status$button_next"

    echo "$note   $title_display   $command_bar"
  '')

  (pkgs.writeScriptBin "launch_radios" ''
    #!/usr/bin/env bash
    set -euxo pipefail
    
    play_youtube() {
      url_stream=$(yt-dlp -g $url_youtube)
      strawberry --play-playlist Youtube  # Loads the playlist so that the current one doesn't get erased by the following 'load' command
      strawberry --load $url_stream
      sleep 1
      strawberry --play-playlist Youtube
    }

    play_radio() {
      strawberry --play-playlist Radios
      strawberry --play-track $track
    }

    # track=0 && play_radio
    MENU="$(echo -n 'FIP|Jazz Radio|Radio Nova|Oui Fm|Chillhop Radio|Classical Piano Music' | rofi -no-config -no-lazy-grab -sep "|" -dmenu -i -p 'radio' \
      -theme $HOME/.config/rofi/theme/styles.rasi)"
        case "$MENU" in
          FIP) track=0 && play_radio ;;
          "Jazz Radio") track=1 && play_radio ;;
          "Radio Nova") track=2 && play_radio ;;
          "Oui Fm") track=3 && play_radio ;;
          "Chillhop Radio") url_youtube=https://www.youtube.com/watch?v=5yx6BWlEVcY && play_youtube && echo "Chillhop Radio" > /home/romain/.config/.radio_title ;;
          "Classical Piano Music") url_youtube=https://www.youtube.com/watch?v=tSlOlKRuudU && play_youtube && echo "Classical Piano Music" > /home/romain/.config/.radio_title;;
        esac
  '')

  (pkgs.writeScriptBin "lock-conky" ''
    #!/usr/bin/env bash
    set -euxo pipefail

    while getopts "s" opt; do
          case $opt in
                s) sleep=true;;
                \?) echo "Invalid option. To sleep, use -s";;
          esac
    done

    THEME=$(ls $HOME/.conky/ | sort -R | tail -1)
    SCREEN_OFF=$(xrandr --query | grep connected | grep -v primary | cut -d ' ' -f 1  )

    # Prepare screen
    pkill xidlehook
    pkill polybar
    wk1=$(i3-msg -t get_workspaces | jq '.[] | select(.visible==true).name' | head -1)
    wk2=$(i3-msg -t get_workspaces | jq '.[] | select(.visible==true).name' | tail -1)
    i3-msg "workspace \" \"; workspace \"  \""
    $HOME/.conky/$THEME/launch.sh
    xrandr --output $SCREEN_OFF --brightness 0


    # Sleep or prepare to sleep
    if [ $sleep ]; then
          systemctl suspend
    else
          xidlehook --timer ${toString (host-specifics.minutes-from-lock-to-sleep * 60)} 'systemctl suspend' ' ' &
    fi
    
    # Lock
    alock -auth passwd -bg none -cursor blank

    # Wake up
    if [ ! $sleep ]; then
          pkill xidlehook
    fi

    # Revert to original config
    i3-msg workspace "$wk1"
    i3-msg workspace "$wk2"
    $HOME/.fehbg
    pkill conky
    $HOME/.config/polybar/launch.sh
    xidlehook --timer ${toString (host-specifics.minutes-before-lock * 60)} 'lock-conky' ' ' &
    xrandr --output $SCREEN_OFF --brightness 1
  '')
]
