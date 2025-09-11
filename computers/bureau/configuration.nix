{ config, ... }:
let
  user = config.by-db.user;
in
{
  imports = [
    ../../nixos/workstation.nix
    ./hardware-configuration.nix
  ];

  by-db = {
    user = {
      name = "romain";
      description = "Romain";
    };
    nix-cores = 2;
    nix-max-jobs = 1;
    nix-high-ram = "7G";
    nix-max-ram = "8G";
  };

  home-manager.users.${user.name} = {
    by-db = {
      minutes-from-lock-to-sleep = 17;
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
