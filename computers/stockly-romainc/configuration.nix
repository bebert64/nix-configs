{ config, ... }:
let
  nixosUserConfig = config.byDb.user;
  homeManagerBydbConfig = config.byDb.hmUser.byDb;
in
{
  imports = [
    ../../nixos/workstation.nix
    ./hardware-configuration.nix
  ];

  byDb = {
    user = {
      name = "user";
      description = "User";
    };
    bluetooth.enable = true;
    nixCores = 4;
    nixMaxJobs = 2;
    nixHighRam = "7G";
    nixMaxRam = "8G";
  };

  home-manager = {
    users.${nixosUserConfig.name} = {
      byDb = {
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
      byDbPkgs.save-autorandr-config = {
        enable = true;
        autorandrConfigsPath = "${homeManagerBydbConfig.paths.nixPrograms}/autorandr.nix";
        defaultBars = "eDP-1-tray-off HDMI-1-battery";
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
