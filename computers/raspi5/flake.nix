{
  description = "Example Raspberry Pi 5 configuration flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
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
              }
            )

            (
              {
                lib,
                modulesPath,
                ...
              }:

              {
                imports = [
                  (modulesPath + "/installer/scan/not-detected.nix")
                ];

                boot.initrd.availableKernelModules = [
                  "usb_storage"
                  "usbhid"
                ];
                boot.initrd.kernelModules = [ ];
                boot.kernelModules = [ ];
                boot.extraModulePackages = [ ];
                boot.loader.raspberryPi.bootloader = lib.mkForce "kernel";

                fileSystems."/" = lib.mkForce {
                  device = "/dev/disk/by-label/nixos";
                  fsType = "ext4";
                };

                fileSystems."/boot" = lib.mkForce {
                  device = "/dev/disk/by-label/boot";
                  fsType = "vfat";
                  options = [
                    "fmask=0077"
                    "dmask=0077"
                  ];
                };

                swapDevices = [ ];

                nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
              }
            )
          ];
        };
      };
    };
}
