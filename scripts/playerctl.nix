{ lib, pkgs, psg, ... }:
rec {
  move = pkgs.writeScriptBin "playerctl-move" ''
    CURRENT_PLAYER=$(playerctl --list-all | head -n 1)

    case $CURRENT_PLAYER in
      "strawberry") playerctl position $2$1;;
      *) playerctl position $(expr $(playerctl position | cut -d . -f 1) $1 $2);;
    esac

  '';

  restart-or-previous = pkgs.writeScriptBin "playerctl-restart-or-previous" ''
    PATH=${
      lib.makeBinPath [
        pkgs.playerctl
        pkgs.coreutils
        pkgs.strawberry
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
  '';

  display-title = pkgs.writeScriptBin "playerctl-display-title" ''
    PATH=${
      lib.makeBinPath [
        pkgs.playerctl
        pkgs.gnugrep
        pkgs.coreutils
      ]
    }

    title=$(playerctl metadata 2> /dev/null | grep xesam:title | tr -s ' ' | cut -d ' ' -f 3-)
    artist=$(playerctl metadata 2> /dev/null | grep xesam:artist | tr -s ' ' | cut -d ' ' -f 3-)

    if [[ $artist ]]; then
      title_display="$artist - $title"
    else
      title_display=$title
    fi

    echo "$title_display"
  '';

  cmd-bar-and-display-title = pkgs.writeScriptBin "playerctl-cmd-bar-and-display-title" ''
    PATH=${
      lib.makeBinPath [
        display-title
        restart-or-previous
      ]
    }
    playerctl=${pkgs.playerctl}/bin/playerctl

    status=$($playerctl status 2> /dev/null)
    previous=
    next=
    play=
    pause=
    stop=

    button_previous="%{A1:playerctl-restart-or-previous:}$previous  %{A}"
    button_play="%{A1:$playerctl play:}  $play  %{A}"
    button_pause="%{A1:$playerctl pause:}  $pause  %{A}"
    button_stop="%{A1:$playerctl -a stop:}  $stop  %{A}"
    button_next="%{A1:$playerctl next:}  $next%{A}"

    if [[ $status == "Playing" ]]; then
      button_status=$button_pause
    else
      button_status=$button_play
    fi

    command_bar="$button_previous$button_stop$button_status$button_next"

    echo "$command_bar     $(playerctl-display-title)"
  '';

  display-title-or-no-music = pkgs.writeScriptBin "playerctl-display-title-or-no-music" ''
    PATH=${lib.makeBinPath [ display-title ]}
    display_title_opt=$(playerctl-display-title)
    if [[ $display_title_opt ]]; then
        echo $display_title_opt
    else
        echo "%{T2}󰝛 %{T-}"
    fi
  '';


  is-music-playing = pkgs.writeScriptBin "is-music-playing" ''
    TITLE="$(playerctl metadata title 2>&1)"
    if [[ "$TITLE" == *"No player could handle this command"* || "$TITLE" == *"No players found"* ]];then
            echo false;
    else
          echo true;
    fi;
  '';

  launch-radios = pkgs.writeScriptBin "launch-radios" ''
    PATH="${lib.makeBinPath [ psg ]}:$PATH"

    play_radio() {
      IS_STRAWBERRY_LAUNCHED=$(psg strawberry)

      if [[ ! $IS_STRAWBERRY_LAUNCHED ]]; then
          strawberry &
      fi

      while [[ ! $IS_STRAWBERRY_LAUNCHED ]]; do
          IS_STRAWBERRY_LAUNCHED=$(psg strawberry)
          sleep 1
      done

      strawberry --play-playlist Radios &
      strawberry --play-track $1 &
    }

    MENU="$(echo -en \
    'FIP\0icon\x1f${../assets/icons/fip.png}
    Jazz Radio\0icon\x1f${../assets/icons/jazz-radio.jpg}
    Radio Nova\0icon\x1f${../assets/icons/nova.jpg}
    Oui FM\0icon\x1f${../assets/icons/Oui-FM.png}
    Classic FM\0icon\x1f${../assets/icons/classic-FM.png}
    Chillhop Radio\0icon\x1f${../assets/icons/chillhop.jpg}' \
    | rofi -dmenu -show-icons -i -p 'Radio')"

    case "$MENU" in
      FIP) play_radio 0 ;;
      "Jazz Radio") play_radio 1 ;;
      "Radio Nova") play_radio 2 ;;
      "Oui FM") play_radio 3 ;;
      "Classic FM") play_radio 4 ;;
      "Chillhop Radio") i3-msg "workspace 10:; exec firefox -new-window https://www.youtube.com/watch\?v\=5yx6BWlEVcY" ;;
    esac
  '';
}
