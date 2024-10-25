{
  description = "NixOS and HomeManager configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ nixpkgs, home-manager, ... }:
    let
      host-specific = {
        stockly-romainc = import ./nix/nixos/stockly-romainc/host-specific.nix;
        raspi = import ./nix/home-manager/raspi/host-specific.nix;
        fixe-bureau = import ./nix/home-manager/fixe-bureau/host-specific.nix;
      };
    in
    {
      nixosModules = {
        stockly-romainc = ./nix/nixos/stockly-romainc/configuration.nix;
      };
      homeConfigurations = {
        raspi = home-manager.lib.homeManagerConfiguration rec {
          pkgs = import nixpkgs {
            system = "aarch64-linux"; # x86_64-linux, aarch64-multiplatform, etc.
          };

          modules = [ (import ./nix/home-manager/home_raspi.nix { inherit pkgs; }) ];
        };

        fixe-bureau = home-manager.lib.homeManagerConfiguration rec {
          pkgs = import nixpkgs {
            system = "x86_64-linux"; # x86_64-linux, aarch64-multiplatform, etc.
            config = {
              allowUnfree = true;
            };
          };

          modules = [
            (import ./nix/home-manager/home.nix {
              inherit pkgs;
              host-specific = host-specific.fixe-bureau;
              lib = nixpkgs.lib;
              hm-lib = home-manager.lib;
            })
          ];
        };
      };
      stocklySpecialArgs = {
        flake-inputs = inputs;
        host-specific = host-specific.stockly-romainc;
      };
    };
}
