{ host-specific
, lib
, pkgs
, ...
}:
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

    status=$(playerctl status 2> /dev/null)
    if [[ $status == "Playing" ]]; then
      prefix=" "
    else
      prefix="󰝛 "
    fi

    echo "%{T2}$prefix %{T-}  $title_display"
  '';

  headphones-or-speaker-icon = pkgs.writeScriptBin "headphones-or-speaker-icon" ''
    PATH=${
      lib.makeBinPath [
        pkgs.gnugrep
        pkgs.pulseaudio
      ]
    }
    IS_HEADPHONES_ON=$(pactl list sinks | grep "${host-specific.playerctl.is-headphones-on-regex}")
    if [[ $IS_HEADPHONES_ON ]]; then
      echo " "
    else
      echo "󰓃 "
    fi
  '';

  set-headphones = pkgs.writeScriptBin "set-headphones" ''
    PATH=${lib.makeBinPath [ pkgs.pulseaudio ]}
    pactl ${host-specific.playerctl.set-headphones}
  '';

  set-speaker = pkgs.writeScriptBin "set-speaker" ''
    PATH=${lib.makeBinPath [ pkgs.pulseaudio ]}
    pactl ${host-specific.playerctl.set-speaker}
  '';
}
