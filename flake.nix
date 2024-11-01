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
    stockly-computers.url = "git+ssh://git@github.com/Stockly/Computers.git";
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      by-db,
      stockly-computers,
      ...
    }:
    let
      hosts-specific = import ./nix/hosts-specific;
    in
    {
      nixosConfigurations.stockly-romainc = stockly-computers.personalComputers.stocklyNixosSystem {
        hostname = "stockly-romainc";
        configuration = ./stockly/configuration.nix;
        specialArgs = {
          inherit stockly-computers home-manager by-db;
          host-specific = hosts-specific.stockly-romainc;
        };
      };

      homeConfigurations = {
        raspi = home-manager.lib.homeManagerConfiguration rec {
          pkgs = import nixpkgs { system = "aarch64-linux"; };

          modules = [ (import ./nix/home-manager/home_raspi.nix { inherit pkgs; }) ];
        };
        fixe-bureau = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "x86_64-linux"; };

          modules = [ ./nix/home-manager/home.nix ];
          extraSpecialArgs = {
            inherit by-db;
            host-specific = hosts-specific.fixe-bureau;
          };
        };
      };
    };
}
