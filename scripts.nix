{ pkgs, ... }:
let
  inherit (pkgs) writeScriptBin;
in
{

  home.packages = [
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
  ];

}
