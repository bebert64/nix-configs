{
  imports = [
    ../../nixos/raspi4.nix
    ./hardware-configuration.nix
  ];

  byDb.user = {
    name = "romain";
    description = "Romain";
  };

  networking = {
    hostName = "raspi4";
  };
}
