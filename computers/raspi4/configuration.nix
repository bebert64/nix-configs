{
  imports = [
    ../../nixos/server.nix
    ./hardware-configuration.nix
  ];

  by-db.user = {
    name = "romain";
    description = "Romain";
  };

  networking = {
    hostName = "raspi4";
  };
}
