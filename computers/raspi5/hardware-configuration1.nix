{ lib, ... }:
{
  fileSystems = {
    "/boot/firmware" = lib.mkForce {
      device = "/dev/disk/by-uuid/2175-794E";
      fsType = "vfat";
      options = [
        "noatime"
        "noauto"
        "x-systemd.automount"
        "x-systemd.idle-timeout=1min"
      ];
    };
    "/" = lib.mkForce {
      device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  # Disable raspberryPi bootloader when building SD image
  # The sd-image module will handle bootloader installation
  boot.loader.raspberryPi.enable = lib.mkDefault false;
}
