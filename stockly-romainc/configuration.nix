{ config, ... }:
let
  user = config.by-db.user;
in
{
  imports = [
    ../nixos.nix
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
    users.${user.name}.by-db = {
      bluetooth.enable = true;
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

  };

  # Configuration options that are not standard NixOS, but were defined by Stockly
  stockly = {
    acer-quanta-webcam-fix = true;
    ui = null;
    nvidia = false;
    auto-update.enable = true; # See auto-update.nix for doc
    keyboard-layout = "fr";
  };

  services = {
    # Enable touchpad support (enabled default in most desktopManager).
    libinput = {
      touchpad.naturalScrolling = true;
      touchpad.middleEmulation = true;
      touchpad.tapping = true;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
