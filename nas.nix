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
in
{

  fileSystems."${nasMountPoint}" = {
    device = "${nasIpAndVolume}";
    fsType = "nfs";
    options = [
      "noexec"
      "noauto"
      "soft"
      "timeo=30"
      "retrans=3"
      "x-systemd.automount"
      "x-systemd.idle-timeout=300"
      "x-systemd.mount-timeout=10s"
    ];
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
