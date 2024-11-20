{
  description = "NixOS and HomeManager configurations";

  inputs = {
    stockly-computers.url = "git+ssh://git@github.com/Stockly/Computers.git";
    nixpkgs.follows = "stockly-computers/nixpkgs";
    nixpkgs-unstable = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    by-db = {
      url = "git+ssh://git@github.com/bebert64/perso";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
    };

  };

  outputs =
    { nixpkgs
    , nixpkgs-unstable
    , home-manager
    , by-db
    , stockly-computers
    , sops-nix
    , ...
    }:
    {
      nixosConfigurations = {
        stockly-romainc = stockly-computers.personalComputers.stocklyNixosSystem {
          hostname = "stockly-romainc";
          configuration = ./stockly-romainc/configuration.nix;
          specialArgs = {
            inherit
              stockly-computers
              home-manager
              by-db
              sops-nix
              ;
          };
        };

        fixe-bureau = nixpkgs.lib.nixosSystem {
          modules = [ ./fixe-bureau/configuration.nix ];
          specialArgs = {
            inherit home-manager by-db sops-nix;
          };
        };

        raspi = nixpkgs.lib.nixosSystem {
          modules = [ ./raspi/configuration.nix ];
          specialArgs = {
            inherit home-manager by-db sops-nix nixpkgs-unstable;
          };
        };
      };
    };
}
