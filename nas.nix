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
  checkNasAvailable =
    let
      timeout = "${pkgs.coreutils}/bin/timeout";
      bash = "${pkgs.bash}/bin/bash";
      showmount = "${pkgs.nfs-utils}/bin/showmount";
      grep = "${pkgs.gnugrep}/bin/grep";
    in
    pkgs.writeShellScript "check-nas-available" ''
      ${timeout} -k 0.5 1 ${bash} -c \
        "exec 3<>/dev/tcp/${nasIp}/2049" 2>/dev/null \
        && ${showmount} -e ${nasIp} --no-headers 2>/dev/null \
          | ${grep} -q '${nasVolume}'
    '';
in
{

  boot.supportedFilesystems = [ "nfs" ];

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
      options = "noexec,noauto,soft,timeo=30,retrans=3,retry=0";
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
      TimeoutStartSec = "3s";
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
