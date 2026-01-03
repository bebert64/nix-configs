{
  description = "Example Raspberry Pi 5 configuration flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
    # disko.url = "github:nix-community/disko";
    # disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-raspberrypi,
    # disko,
    }@inputs:
    {
      nixosConfigurations = {
        raspi5 = nixos-raspberrypi.lib.nixosSystem {
          specialArgs = inputs;
          modules = [
            (
              { ... }:
              {
                imports = with nixos-raspberrypi.nixosModules; [
                  raspberry-pi-5.base
                ];
              }
            )
            (
              { ... }:
              {
                networking.hostName = "raspi5";
                users.users.yourUserName = {
                  initialPassword = "Tnepres64!";
                  isNormalUser = true;
                  extraGroups = [
                    "wheel"
                  ];
                };

                services.openssh.enable = true;
                boot.loader.raspberryPi.bootloader = "kernel";
              }
            )

            # disko.nixosModules.disko
            ./hardware-configuration.nix
            # ./disk-config.nix
          ];
        };
      };
    };
}
