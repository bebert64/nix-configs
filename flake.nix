{
  description = "NixOS and HomeManager configurations";

  inputs = {
    stockly-computers.url = "git+ssh://git@github.com/Stockly/Computers.git";
    nixpkgs.follows = "stockly-computers/nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "stockly-computers/nixpkgs";
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
      stockly-computers,
      ...
    }:
    let
      hosts-specific = import ./hosts-specific;
    in
    {
      nixosConfigurations = {
        stockly-romainc = stockly-computers.personalComputers.stocklyNixosSystem {
          hostname = "stockly-romainc";
          configuration = ./nixos/stockly-romainc/configuration.nix;
          specialArgs = {
            inherit stockly-computers home-manager by-db;
            host-specific = hosts-specific.stockly-romainc;
          };
        };

        fixe-bureau = nixpkgs.lib.nixosSystem {
          modules = [ ./nixos/fixe-bureau/configuration.nix ];
          specialArgs = {
            inherit stockly-computers home-manager by-db;
            host-specific = hosts-specific.fixe-bureau;
          };
        };
      };

      homeConfigurations = {
        raspi = home-manager.lib.homeManagerConfiguration rec {
          pkgs = import nixpkgs { system = "aarch64-linux"; };

          modules = [ (import ./home-manager/home_raspi.nix { inherit pkgs; }) ];
        };
        fixe-bureau = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "x86_64-linux"; };

          modules = [ ./home-manager/home.nix ];
          extraSpecialArgs = {
            inherit by-db;
            host-specific = hosts-specific.fixe-bureau;
          };
        };
      };
    };
}
