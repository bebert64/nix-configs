{
  description = "NixOS and HomeManager configurations";

  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
    # Increase download buffer size to avoid warnings when downloading large files
    # 256 MB (268435456 bytes) should be sufficient for most builds
    download-buffer-size = 268435456;
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/develop";

    by-db = {
      url = "git+ssh://git@github.com/bebert64/perso?ref=main";
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
      nixos-raspberrypi,
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

        raspi5 = nixos-raspberrypi.lib.nixosSystem {
          modules = [ ./computers/raspi5/configuration.nix ];
          specialArgs = {
            inherit
              nixos-raspberrypi
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
