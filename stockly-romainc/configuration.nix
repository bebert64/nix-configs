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
      name = "user";
      description = "User";
    };
    bluetooth.enable = true;
    nix-cores = 4;
    nix-max-jobs = 2;
    nix-max-ram = "8G";
  };

  home-manager = {
    users.${user.name} = {
      by-db = {
        wifi.enable = true;
        nixConfigsRepo = "nix-config";
        isHeadphonesOnCommand = "pactl info | grep \"Default Sink.*Headphones\"";
        setHeadphonesCommand = "set-card-profile 'alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic' 'HiFi (HDMI1, HDMI2, HDMI3, Headphones, Mic1, Mic2)'";
        setSpeakerCommand = "set-card-profile 'alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic' 'HiFi (HDMI1, HDMI2, HDMI3, Mic1, Mic2, Speaker)'";
        screens = {
          primary = "eDP-1";
          secondary = "HDMI-1";
        };
      };
      by-db-pkgs.save-autorandr-config = {
        enable = true;
        default-bars = "eDP-1-tray-off HDMI-1-battery";
      };
    };
  };

  # Configuration options that are not standard NixOS, but were defined by Stockly
  stockly = {
    acer-quanta-webcam-fix = true;
    ui = null;
    nvidia = false;
    auto-update.enable = true; # See auto-update.nix for doc
    keyboard-layout = "fr";
  };
}
