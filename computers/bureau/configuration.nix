{ config, ... }:
let
  user = config.byDb.user;
in
{
  imports = [
    ../../nixos/workstation.nix
    ./hardware-configuration.nix
  ];

  byDb = {
    user = {
      name = "romain";
      description = "Romain";
    };
    nixCores = 2;
    nixMaxJobs = 1;
    nixHighRam = "7G";
    nixMaxRam = "8G";
  };

  home-manager.users.${user.name} = {
    byDb = {
      minutesBeforeLock = 10;
      minutesFromLockToSleep = 10;
      screens = {
        primary = "HDMI-1";
        secondary = "HDMI-2";
      };
      isHeadphonesOnCommand = "pactl get-default-sink | grep alsa_output.pci-0000_00_1b.0.analog-stereo";
      setHeadphonesCommand = "set-default-sink alsa_output.pci-0000_00_1b.0.analog-stereo";
      setSpeakerCommand = "set-default-sink alsa_output.pci-0000_01_00.1.hdmi-stereo-extra2";
    };
  };

  networking = {
    hostName = "bureau";
    interfaces.enp3s0.wakeOnLan.enable = true;
  };
}
