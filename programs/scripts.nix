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

      mnas
      rsync -avh --exclude "Fond pour téléphone" $HOME/mnt/NAS/Wallpapers/ ~/wallpapers
      rsync -avh ~/wallpapers/ $HOME/mnt/NAS/Wallpapers
    '')
  ];

}
