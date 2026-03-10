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
  nasVolume = "/volume1/NAS";
  nasIpAndVolume = "${nasIp}:${nasVolume}";
  nasMountPoint = "/mnt/NAS";
  homeDir = config.byDb.hmUser.home.homeDirectory;
  homeMountDir = "${homeDir}/mnt/";
  unmountNas = writeScriptBin "unmount-nas" ''
    PATH=${makeBinPath [ pkgs.util-linux ]}
    set -euo pipefail
    if mountpoint -q ${nasMountPoint} ; then
      umount -l ${nasMountPoint}
      echo "NAS unmounted"
    else
      echo "NAS is not mounted"
    fi
  '';
  checkNasAvailable = pkgs.writeShellScript "check-nas-available" ''
    PATH=${makeBinPath [ pkgs.nfs-utils pkgs.coreutils pkgs.gnugrep ]}
    timeout 2 showmount -e ${nasIp} --no-headers 2>/dev/null | grep -q '${nasVolume}'
  '';
in
{

  systemd.automounts = [
    {
      where = nasMountPoint;
      wantedBy = [ "multi-user.target" ];
      automountConfig.TimeoutIdleSec = "300";
    }
  ];

  systemd.mounts = [
    {
      what = nasIpAndVolume;
      where = nasMountPoint;
      type = "nfs";
      options = "noexec,noauto,soft,timeo=30,retrans=3";
      requires = [ "check-nas-available.service" ];
      after = [ "check-nas-available.service" ];
      mountConfig.TimeoutSec = "10s";
    }
  ];

  systemd.services.check-nas-available = {
    description = "Check that the NAS at ${nasIp} exports ${nasVolume}";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = checkNasAvailable;
    };
  };

  environment.systemPackages = [
    unmountNas
  ];

  home-manager.users.${config.byDb.user.name} = {
    byDb.paths.nasBase = nasMountPoint;
    programs.zsh.shellAliases = {
      umnas = "unmount-nas";
    };
    home.activation = {
      symlinkMountDirNas = home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p ${homeMountDir}
        ln -sfT ${nasMountPoint} ${homeMountDir}/NAS
      '';
    };
  };

}
