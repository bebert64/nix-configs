{
  pkgs,
  lib,
  config,
  home-manager,
  ...
}:
let
  inherit (pkgs) writeScriptBin;
  inherit (lib) makeBinPath;
  mountNas = writeScriptBin "mount-nas" ''
    PATH=${
      makeBinPath [
        pkgs.curlMinimal
        pkgs.toybox # contains mkdir, grep and ping
        unmountNas
      ]
    }
    set -euo pipefail

    IP=192.168.1.30
    NAME=NasLaFouillouse

    mkdir -p /mnt/NAS

    if [[ $(ls /mnt/NAS) ]]; then
      echo "NAS seems to already be mounted"
      exit
    fi

    if ! ping -c1 $IP &> /dev/null; then
      echo "No machine responding at $IP"
      unmount-nas
      exit
    fi

    if [[ $(curl -s $IP:5000 | grep $NAME) ]]; then
      # We specifically want to avoid using toybox's mount, which doesn't work with nfs
      ${pkgs.mount}/bin/mount $IP:/volume1/NAS /mnt/NAS
      echo "mounted $NAME successfully"
    else
      echo "The machine at $IP seems to not be $NAME"
      unmount-nas
    fi
  '';
  unmountNas = writeScriptBin "unmount-nas" ''
    PATH=${makeBinPath [ pkgs.util-linux ]}
    if mountpoint -q /mnt/NAS ; then
      umount /mnt/NAS 
    fi
  '';
in
{

  fileSystems."/mnt/NAS" = {
    device = "192.168.1.3:/volume1/NAS";
    fsType = "nfs";
    options = [
      "noexec"
      "noauto"
    ];
  };

  systemd = {
    services = {
      mount-nas = {
        script = "${mountNas}/bin/mount-nas";
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
      };
    };
    timers = {
      mount-nas = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "20s";
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

  home-manager.users.${config.by-db.user.name} = {
    programs.zsh.shellAliases = {
      mnas = "sudo mount-nas";
      umnas = "sudo unmount-mnas";
    };
    home.activation = {
      symlinkMountDirNas = home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p $HOME/mnt/
        ln -sf /mnt/NAS $HOME/mnt/
      '';
    };
  };

}
