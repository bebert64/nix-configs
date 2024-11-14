{ pkgs, lib, ... }:
let
  inherit (pkgs) writeScriptBin;
  inherit (lib) makeBinPath;
  mountNas = writeScriptBin "mnas" ''
    PATH=${
      makeBinPath (
        with pkgs;
        [
          curlMinimal
          toybox # contains mkdir, grep and ping
        ]
      )
    }
    set -euo pipefail

    IP=192.168.1.3
    NAME=NasLaFouillouse

    mkdir -p /mnt/NAS

    if [[ $(ls /mnt/NAS) ]]; then
      echo "NAS seems to already be mounted"
      exit
    fi

    if ! ping -c1 $IP &> /dev/null; then
      echo "No machine responding at $IP"
      ${unmountNas}/bin/umnas
      exit
    fi

    if [[ $(curl -s $IP:5000 | grep $NAME) ]]; then
      # We specifically want to avoid using toybox's mount, which doesn't work with nfs
      ${pkgs.mount}/bin/mount $IP:/volume1/NAS /mnt/NAS
      echo "mounted $NAME successfully"
    else
      echo "The machine at $IP seems to not be $NAME"
      ${unmountNas}/bin/umnas
    fi
  '';
  unmountNas = writeScriptBin "umnas" ''
    PATH=${
      makeBinPath (
        with pkgs;
        [
          umount
        ]
      )
    }
    # We want the exit code to be 0 even if the NAS is already unmounted
    # This is because in case of fail, the timer doesn't retry in 5 min (to check actually...)
    umount /mnt/NAS || exit 0
  '';
in
{

  fileSystems."/mnt/NAS" = {
    device = "192.168.1.3:/volume1/NAS";
    fsType = "nfs";
    options = [
      "user"
      "users"
      "noexec"
      "noauto"
    ];
  };

  systemd = {
    services = {
      mount-nas = {
        script = "${mountNas}/bin/mnas";
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
      };
    };
    timers = {
      mount-nas = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "30s";
          OnUnitInactiveSec = "5m";
          OnUnitActiveSec = "5m";
          Unit = "mount-nas.service";
        };
      };
    };
  };

  environment.systemPackages = [
    mountNas
    unmountNas
  ];

}
