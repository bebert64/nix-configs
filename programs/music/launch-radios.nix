{ pkgs, ... }:
let
  inherit (pkgs) writeScriptBin;
in
{
  home.packages = [
    (writeScriptBin "choose-radios" ''
      psg() {
        ps aux | grep $1 | grep -v grep
      }

      play-radio() {
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
      'FIP\0icon\x1f${./icons/fip.png}
      FIP Jazz\0icon\x1f${./icons/fip-jazz.png}
      FIP Rock\0icon\x1f${./icons/fip-rock.png}
      FIP Groove\0icon\x1f${./icons/fip.png}
      FIP Reggae\0icon\x1f${./icons/fip.png}
      FIP Pop\0icon\x1f${./icons/fip.png}
      FIP Monde\0icon\x1f${./icons/fip.png}
      FIP Nouveautés\0icon\x1f${./icons/fip.png}
      Radio Nova\0icon\x1f${./icons/nova.jpg}
      Radio Swiss Classic\0icon\x1f${./icons/fip.png}
      Chillhop Music\0icon\x1f${./icons/chillhop.jpg}' \
      | rofi -dmenu -show-icons -i -p 'Radio')"

      case "$MENU" in
        FIP) play-radio 0 ;;
        "FIP Jazz") play-radio 1 ;;
        "FIP Rock") play-radio 2 ;;
        "FIP Groove") play-radio 3 ;;
        "FIP Reggae") play-radio 4 ;;
        "FIP Pop") play-radio 5 ;;
        "FIP Monde") play-radio 6 ;;
        "FIP Nouveautés") play-radio 7 ;;
        "Radio Nova") play-radio 8 ;;
        "Radio Swiss Classic") play-radio 9 ;;
        "Chillhop Music") play-radio 10 ;;
      esac
    '')
  ];
}
