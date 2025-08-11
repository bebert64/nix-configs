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
        sleep 1
        strawberry --play-track $1 &
      }

      MENU="$(echo -en \
      'FIP\0icon\x1f${./icons/fip.png}
      FIP Jazz\0icon\x1f${./icons/fip-jazz.png}
      Piano Zen\0icon\x1f${./icons/piano-zen.jpg}
      FIP Rock\0icon\x1f${./icons/fip-rock.jpg}
      FIP Groove\0icon\x1f${./icons/fip-groove.jpg}
      FIP Reggae\0icon\x1f${./icons/fip-reggae.jpg}
      FIP Pop\0icon\x1f${./icons/fip-pop.jpg}
      FIP Monde\0icon\x1f${./icons/fip-monde.jpg}
      FIP Nouveautés\0icon\x1f${./icons/fip-nouveautes.jpg}
      Radio Nova\0icon\x1f${./icons/nova.jpg}
      Radio Swiss Classic\0icon\x1f${./icons/radio-swiss-classic.png}
      Chillhop Music\0icon\x1f${./icons/chillhop.jpg}' \
      | rofi -dmenu -show-icons -i -p 'Radio')"

      case "$MENU" in
        FIP) play_radio 0 ;;
        "FIP Jazz") play_radio 1 ;;
        "FIP Rock") play_radio 2 ;;
        "FIP Groove") play_radio 3 ;;
        "FIP Reggae") play_radio 4 ;;
        "FIP Pop") play_radio 5 ;;
        "FIP Monde") play_radio 6 ;;
        "FIP Nouveautés") play_radio 7 ;;
        "Radio Nova") play_radio 8 ;;
        "Radio Swiss Classic") play_radio 9 ;;
        "Chillhop Music") play_radio 10 ;;
        "Piano Zen") play_radio 11 ;;
      esac
    '')
  ];
}
