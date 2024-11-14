{ pkgs, ... }:
let
  inherit (pkgs) writeScriptBin;
in
{

  home.packages = [
    (writeScriptBin "launch-radios" ''
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
        strawberry --play-track $1 &
      }

      MENU="$(echo -en \
      'FIP\0icon\x1f${./assets/icons/fip.png}
      Jazz Radio\0icon\x1f${./assets/icons/jazz-radio.jpg}
      Radio Nova\0icon\x1f${./assets/icons/nova.jpg}
      Oui FM\0icon\x1f${./assets/icons/Oui-FM.png}
      Classic FM\0icon\x1f${./assets/icons/classic-FM.png}
      Chillhop Radio\0icon\x1f${./assets/icons/chillhop.jpg}' \
      | rofi -dmenu -show-icons -i -p 'Radio')"

      case "$MENU" in
        FIP) play_radio 0 ;;
        "Jazz Radio") play_radio 1 ;;
        "Radio Nova") play_radio 2 ;;
        "Oui FM") play_radio 3 ;;
        "Classic FM") play_radio 4 ;;
        "Chillhop Radio") i3-msg "workspace 10:; exec firefox -new-window https://www.youtube.com/watch\?v\=5yx6BWlEVcY" ;;
      esac
    '')
  ];

}
