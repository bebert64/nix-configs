{ pkgs, ... }:
let
  inherit (pkgs) writeScriptBin;
in
{

  home.packages = [
    (writeScriptBin "psg" ''
      set -euo pipefail

      ps aux | grep $1 | grep -v psg | grep -v grep
    '')

    (writeScriptBin "run" ''
      set -euxo pipefail

      nix run "nixpkgs#$1" -- "''${@:2}"
    '')

    (writeScriptBin "sshr" ''
      set -euo pipefail

      REMOTE=$1

      case $REMOTE in
        "cerberus") CMD="nix run \"nixpkgs#ranger\"";;
        *) CMD="ranger";;
      esac

      tilix -p Ranger -e "ssh $REMOTE -t ''${CMD}"
    '')

    (writeScriptBin "sync-wallpapers" ''
      set -euxo pipefail

      mount-nas
      rsync -avh --exclude "Fond pour téléphone" $HOME/mnt/NAS/Wallpapers/ ~/wallpapers
      rsync -avh ~/wallpapers/ $HOME/mnt/NAS/Wallpapers
    '')
  ];

}

# ## Script for reference

# ```bash
# #!/usr/bin/env bash
# set -euxo pipefail

# for n in $(seq 1 $#); do
#     echo $1
#     mkdir zip
#     zip "zip/$1.zip" "$1"/*
#     rsync --progress "zip/$1.zip" /home/romain/mnt/Ipad/Chunky
#     rsync --progress "$1" /home/romain/mnt/Ipad/Chunky
#     shift
# done
# ```
