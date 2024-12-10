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
  };

  home-manager = {
    users.${user.name} = {
      by-db = {
        wifi.enable = true;
        nixConfigsRepo = "nix-config";
        isHeadphonesOnCommand = "pactl list sinks | grep \"Active Port.*Headphones\"";
        setHeadphonesCommand = "set-sink-port 56 '[Out] Headphones'";
        setSpeakerCommand = "set-sink-port 56 '[Out] Speaker'";
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
