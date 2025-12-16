{
  description = "NixOS and HomeManager configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    by-db = {
      url = "git+ssh://git@github.com/bebert64/perso";
      # url = "git+ssh://git@github.com/bebert64/perso?ref=branch_name";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stockly-computers = {
      url = "git+ssh://git@github.com/Stockly/Computers.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      by-db,
      home-manager,
      nixpkgs-unstable,
      nixpkgs,
      sops-nix,
      stockly-computers,
      vscode-server,
      ...
    }:
    let
      pkgs-unstable = import nixpkgs-unstable {
        system = "x86_64-linux";
        # To use Cursor, we need to allow the installation of non-free software.
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations = {
        bureau = nixpkgs.lib.nixosSystem {
          modules = [ ./computers/bureau/configuration.nix ];
          specialArgs = {
            inherit
              by-db
              home-manager
              pkgs-unstable
              sops-nix
              ;

          };
        };

        raspi = nixpkgs.lib.nixosSystem {
          modules = [ ./computers/raspi/configuration.nix ];
          specialArgs = {
            inherit
              by-db
              home-manager
              nixpkgs
              sops-nix
              vscode-server
              ;
          };
        };

        salon = nixpkgs.lib.nixosSystem {
          modules = [ ./computers/salon/configuration.nix ];
          specialArgs = {
            inherit
              by-db
              home-manager
              pkgs-unstable
              sops-nix
              vscode-server
              ;
          };
        };

        stockly-romainc = stockly-computers.personalComputers.stocklyNixosSystem {
          hostname = "stockly-romainc";
          configuration = ./computers/stockly-romainc/configuration.nix;
          specialArgs = {
            inherit
              by-db
              home-manager
              pkgs-unstable
              sops-nix
              stockly-computers
              ;
          };
        };
      };
    };
}
