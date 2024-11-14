{ pkgs, ... }:
let
  inherit (pkgs) writeScriptBin;
in
{

  home.packages = [
    (writeScriptBin "mnas" ''
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
        exit 1
      fi

      if [[ $(curl -s ''${IP}:5000 | grep ''${NAME}) ]]; then
        sudo mount ''${IP}:/volume1/NAS /mnt/NAS
        echo "mounted ''${NAME} successfully"
      else
        echo "The machine at ''${IP} seems to not be ''${NAME}"
        exit 1
      fi 
    '')

    (writeScriptBin "umnas" ''
      #!/usr/bin/env bash
      set -euo pipefail

      sudo umount /mnt/NAS
    '')

    (writeScriptBin "psg" ''
      #!/usr/bin/env bash
      set -euo pipefail

      ps aux | grep $1 | grep -v psg | grep -v grep
    '')

    (writeScriptBin "run" ''
      #!/usr/bin/env bash
      set -euxo pipefail

      nix run "nixpkgs#$1" -- "''${@:2}"
    '')

    (writeScriptBin "sshr" ''
      #!/usr/bin/env bash
      set -euo pipefail

      REMOTE=$1

      case $REMOTE in
        "cerberus") CMD="nix run \"nixpkgs#ranger\"";;
        *) CMD="ranger";;
      esac

      tilix -p Ranger -e "ssh ''$1 -t ''${CMD}"
    '')

    (writeScriptBin "sync-wallpapers" ''
      #!/usr/bin/env bash
      set -euxo pipefail

      mnas
      rsync -avh --exclude "Fond pour téléphone" $HOME/mnt/NAS/Wallpapers/ ~/wallpapers
      rsync -avh ~/wallpapers/ $HOME/mnt/NAS/Wallpapers
    '')

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
