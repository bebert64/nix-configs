{ nixos-raspberrypi, lib, ... }:
{
  imports = [
    ../../nixos/server.nix
    ./hardware-configuration.nix
    (
      { ... }:
      {
        imports = with nixos-raspberrypi.nixosModules; [
          raspberry-pi-5.base
          raspberry-pi-5.page-size-16k
          raspberry-pi-5.display-vc4
        ];
      }
    )
  ];

  by-db.user = {
    name = "romain";
    description = "Romain";
  };

  networking = {
    hostName = "raspi";
  };

  # Disable raspberryPi bootloader when building SD image to avoid conflicts
  # The sd-image module will handle bootloader installation
  boot.loader.raspberryPi.enable = lib.mkForce false;

  # Configure home-manager to use the system's pkgs to avoid package collisions
  # This ensures home-manager uses the same nixpkgs as nixos-raspberrypi
  home-manager.useGlobalPkgs = true;
  nixpkgs.config.allowUnfree = true;
}
