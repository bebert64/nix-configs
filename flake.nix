{
  description = "NixOS and HomeManager configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    by-db = {
      url = "git+ssh://git@github.com/bebert64/perso";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      by-db,
      ...
    }:
    let
      host-specific = {
        stockly-romainc = import ./nix/nixos/stockly-romainc/host-specific.nix;
        raspi = import ./nix/host-specific/raspi.nix;
        fixe-bureau = import ./nix/host-specific/fixe-bureau.nix;
      };
    in
    {
      stockly-romainc = {
        nixosModule = ./nix/nixos/stockly-romainc/configuration.nix;
        specialArgs = {
          inherit inputs;
          host-specific = host-specific.stockly-romainc;
        };
      };
      homeConfigurations = {
        raspi = home-manager.lib.homeManagerConfiguration rec {
          pkgs = import nixpkgs { system = "aarch64-linux"; };

          modules = [ (import ./nix/home-manager/home_raspi.nix { inherit pkgs; }) ];
        };

        fixe-bureau = home-manager.lib.homeManagerConfiguration rec {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            # config = {
            #   allowUnfree = true;
            # };
          };

          modules = [
            (import ./nix/home-manager/home.nix {
              inherit pkgs by-db;
              host-specific = host-specific.fixe-bureau;
              lib = nixpkgs.lib;
              hm-lib = home-manager.lib;
            })
          ];
        };
      };
    };
}
