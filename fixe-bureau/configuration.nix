{ config, ... }:
let
  user = config.by-db.user;
in
{
  imports = [
    ../nixos/workstation.nix
    ./hardware-configuration.nix
  ];

  by-db = {
    user = {
      name = "romain";
      description = "Romain";
    };
    nix-cores = 2;
    nix-max-jobs = 1;
  };

  home-manager.users.${user.name} = {
    by-db = {
      minutes-before-lock = 5;
      minutes-from-lock-to-sleep = 15;
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
    hostName = "fixe-bureau";
    interfaces.enp3s0.wakeOnLan.enable = true;
  };
}
