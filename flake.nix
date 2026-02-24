{
  description = "NixOS and HomeManager configurations";

  nixConfig = {
    # Increase download buffer size to avoid warnings when downloading large files
    # 256 MB (268435456 bytes) should be sufficient for most builds
    download-buffer-size = 268435456;
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
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
      nixpkgs-unstable,
      nixpkgs,
      sops-nix,
      stockly-computers,
      vscode-server,
      ...
    }:
    let
      pkgsUnstable = import nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      mkHost =
        {
          modules,
          extraSpecialArgs ? { },
        }:
        nixpkgs.lib.nixosSystem {
          modules = modules;
          specialArgs = {
            inherit
              home-manager
              nixpkgs
              sops-nix
              ;
          }
          // extraSpecialArgs;
        };
    in
    {
      packages.x86_64-linux.home-manager = home-manager.packages.x86_64-linux.home-manager;

      homeConfigurations."romain@cerberus" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./home-manager/cerberus.nix ];
      };

      nixosConfigurations = {
        bureau = mkHost {
          modules = [ ./computers/bureau/configuration.nix ];
          extraSpecialArgs = { inherit by-db pkgsUnstable; };
        };

        raspi4 = mkHost {
          modules = [ ./computers/raspi4/configuration.nix ];
          extraSpecialArgs = { inherit vscode-server; };
        };

        salon = mkHost {
          modules = [ ./computers/salon/configuration.nix ];
          extraSpecialArgs = {
            inherit
              by-db
              pkgsUnstable
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
              pkgsUnstable
              sops-nix
              stockly-computers
              ;
          };
        };
      };
    };
}
