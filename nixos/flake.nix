{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
      fixe-bureau = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./fixe-bureau/configuration.nix
        ];
        specialArgs = {
          flake-inputs = inputs;
          host-specific = import ./fixe-bureau/host-specifics.nix;
        };
      };
      fixe-salon = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./fixe-salon/configuration.nix
        ];
        specialArgs = {
          flake-inputs = inputs;
          host-specific = import ./fixe-salon/host-specifics.nix;
        };
      };
      stockly-romainc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./stockly-romainc/configuration.nix
        ];
        specialArgs = {
          flake-inputs = inputs;
          host-specific = import ./stockly-romainc/host-specifics.nix;
        };
      };
    };
  };
}
