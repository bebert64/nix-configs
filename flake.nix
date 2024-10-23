{
  description = "NixOS and HomeManager configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ nixpkgs, home-manager, ... }:
    let
      raspi = "raspi";
      fixe-bureau = "fixe-bureau";
      config = {
        allowUnfree = true;
      };
    in
    {
      nixosModules = {
        stockly-romainc = ./nix/nixos/stockly-romainc/configuration.nix;
      };
      nixosSpecialArgs = {
        flake-inputs = inputs;
        host-specific.stockly-romainc = import ./nix/nixos/stockly-romainc/host-specific.nix;
      };
      homeConfigurations = {
        ${raspi} = home-manager.lib.homeManagerConfiguration rec {
          pkgs = import nixpkgs {
            system = "aarch64-linux"; # x86_64-linux, aarch64-multiplatform, etc.
            inherit config;
          };

          modules = [
            (import ./nix/home-manager/home_raspi.nix {
              config-name = raspi;
              inherit pkgs;
            })
          ];
        };

        ${fixe-bureau} = home-manager.lib.homeManagerConfiguration rec {
          pkgs = import nixpkgs {
            system = "x86_64-linux"; # x86_64-linux, aarch64-multiplatform, etc.
            inherit config;
          };

          modules =
            let
              host-specifics = import ./home-manager/fixe-bureau/host_specifics.nix;
            in
            [
              (import ./nix/home-manager/home.nix {
                config-name = fixe-bureau;
                inherit pkgs config host-specifics;
                lib = nixpkgs.lib;
                hm-lib = home-manager.lib;
              })
            ];
        };
      };
    };
}
