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
  ];

}
