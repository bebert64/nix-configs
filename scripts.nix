{ pkgs
, lib
, config
, ...
}:
{
  options.by-db.scripts = with lib; {
    minutes-before-lock = mkOption {
      type = types.int;
      default = 3;
      description = "Minutes before the computer locks itself";
    };
    minutes-from-lock-to-sleep = mkOption {
      type = types.int;
      default = 7;
      description = "Minutes from the moment the computer locks itself to the moment it starts sleeping";
    };
    set-headphones = mkOption {
      type = types.str;
      description = "Command to redirect the sound output to headphones";
    };
    set-speaker = mkOption {
      type = types.str;
      description = "Command to redirect the sound output to speaker";
    };
  };

  config =
    let
      cfg = config.by-db.scripts;
    in
    {
      home.packages = with pkgs; [
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

        (writeScriptBin "is-music-playing" ''
          TITLE="$(playerctl metadata title 2>&1)"
          if [[ "$TITLE" == *"No player could handle this command"* || "$TITLE" == *"No players found"* ]];then
                  echo false;
          else
                echo true;
          fi;
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

        (writeScriptBin "lock-conky" ''
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
            xidlehook --timer ${toString (cfg.minutes-from-lock-to-sleep * 60)} 'systemctl suspend' ' ' &
          fi

          # Lock
          alock -bg none -cursor blank

          # Revert to original config
          i3-msg workspace "$wk1"
          i3-msg workspace "$wk2"
          systemctl --user restart polybar
          pkill xidlehook || echo "xidlehook already killed"
          xidlehook --timer ${toString (cfg.minutes-before-lock * 60)} 'lock-conky' ' ' &
        '')

        (writeScriptBin "playerctl-move" ''
          CURRENT_PLAYER=$(playerctl --list-all | head -n 1)

          case $CURRENT_PLAYER in
            "strawberry") playerctl position $2$1;;
            *) playerctl position $(expr $(playerctl position | cut -d . -f 1) $1 $2);;
          esac

        '')

        (writeScriptBin "playerctl-restart-or-previous" ''
          PATH=${
            lib.makeBinPath [
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
        '')
      ];
    };
}
