{ pkgs
, specialArgs
, lib
, ...
}:

let
  username = "romain";
in
{
  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  users.users.${username} = {
    isNormalUser = true;
    description = lib.mkDefault "Romain";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGJxBmEvziBiowhj2vd0fbExl4b5Dkf/5rSBjnw3iMbV romain@stockly.ai"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGjhHLih5ykkFc2kOGxVboxjnUARDNMn4/ptovfaNceC bebert64@gmail.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILl4CdsJeD+h9xmNfuSPSHHFz6N9pWfa0uCIYq2b1sGR romain@fixe-salon"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJoCrtZ5Gy9g7kLEhyqVyvdHIVgCq/hhZuY5ghu9GLzc bebert64@gmail.com"
    ];
  };

  home-manager = {
    users.${username} = {
      imports = [ ../../home-manager/home.nix ];
      by-db.username = "${username}";
    };
    backupFileExtension = "bckp";
    extraSpecialArgs = specialArgs;

  };

  services = {
    xserver.windowManager.i3.package = pkgs.i3-gaps;
  };
  networking.hostName = "fixe-bureau";

  nixpkgs.config.allowUnfree = true;

  # Set your time zone.
  time.timeZone = lib.mkDefault "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = lib.mkDefault "en_US.utf8";

  i18n.extraLocaleSettings = lib.mkDefault {
    LC_ADDRESS = "fr_FR.utf8";
    LC_IDENTIFICATION = "fr_FR.utf8";
    LC_MEASUREMENT = "fr_FR.utf8";
    LC_MONETARY = "fr_FR.utf8";
    LC_NAME = "fr_FR.utf8";
    LC_NUMERIC = "fr_FR.utf8";
    LC_PAPER = "fr_FR.utf8";
    LC_TELEPHONE = "fr_FR.utf8";
    LC_TIME = "fr_FR.utf8";
  };

  # Configure console keymap
  console.keyMap = lib.mkDefault "fr";
  hardware.pulseaudio.enable = true;

  # X11 Configuration
  services.xserver = {
    enable = true;
    xkb.layout = lib.mkDefault "fr";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
