{ pkgs, specialArgs, lib, ... }:
{
  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];

  # Configuration options that are not standard NixOS, but were defined by Stockly
  stockly = {
    acer-quanta-webcam-fix = true;
    ui = null;
    nvidia = false;
    auto-update.enable = true; # See auto-update.nix for doc
    keyboard-layout = "fr";
  };

  home-manager = {
    users.user = {
      # home = {
      #   username = lib.mkForce "user";
      #   homeDirectory = lib.mkForce "/home/user";
      # };
      imports = [ ../../home-manager/home.nix ];
      by-db = {
        scripts = {
          set-headphones = "set-sink-port 56 '[Out] Headphones'";
          set-speaker = "set-sink-port 56 '[Out] Speaker'";
        };
        polybar = {
          is-headphones-on-regex = "Active Port.*Headphones";
        };
      };
    };
    backupFileExtension = "bckp";
    extraSpecialArgs = specialArgs;
  };

  services = {
    xserver.windowManager.i3.package = pkgs.i3-gaps;

    displayManager.autoLogin = {
      enable = true;
      user = "user";
    };

    # Enable touchpad support (enabled default in most desktopManager).
    libinput = {
      touchpad.naturalScrolling = true;
      touchpad.middleEmulation = true;
      touchpad.tapping = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
