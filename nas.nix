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
  nasIp = "192.168.1.3";
  nasIpAndVolume = "${nasIp}:/volume1/NAS";
  nasMountPoint = "/mnt/NAS";
  nasName = "NasLaFouillouse";
  nasPort = "5000";
  homeMountDir = "$HOME/mnt/";
  mountNas = writeScriptBin "mount-nas" ''
    PATH=${
      makeBinPath [
        pkgs.curlMinimal
        pkgs.toybox # contains mkdir, grep and ping
        unmountNas
      ]
    }
    set -euo pipefail

    mkdir -p ${nasMountPoint}

    if [[ $(ls ${nasMountPoint}) ]]; then
      echo "NAS seems to already be mounted"
      exit
    fi

    if ! ping -c1 ${nasIp} &> /dev/null; then
      echo "No machine responding at ${nasIp}"
      unmount-nas
      exit
    fi

    if [[ $(curl -s ${nasIp}:${nasPort} | grep ${nasName}) ]]; then
      # We specifically want to avoid using toybox's mount, which doesn't work with nfs
      ${pkgs.mount}/bin/mount ${nasIpAndVolume} ${nasMountPoint}
      echo "mounted ${nasName} successfully"
    else
      echo "The machine at ${nasIp} seems to not be ${nasName}"
      unmount-nas
    fi
  '';
  unmountNas = writeScriptBin "unmount-nas" ''
    PATH=${makeBinPath [ pkgs.util-linux ]}
    if mountpoint -q ${nasMountPoint} ; then
      umount ${nasMountPoint} 
    fi
  '';
in
{

  fileSystems."${nasMountPoint}" = {
    device = "${nasIpAndVolume}";
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
        mkdir -p ${homeMountDir}
        ln -sf ${nasMountPoint} ${homeMountDir}
      '';
    };
  };

}
