{ nixos-raspberrypi, ... }:
{
  imports = [
    ../../nixos/server.nix
    ./hardware-configuration.nix
    (
      { ... }:
      {
        imports = with nixos-raspberrypi.nixosModules; [
          raspberry-pi-5.base
          raspberry-pi-5.bluetooth
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
}
