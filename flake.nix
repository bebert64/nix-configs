{
  description = "NixOS and HomeManager configurations";

  nixConfig = {
    # Increase download buffer size to avoid warnings when downloading large files
    # 256 MB (268435456 bytes) should be sufficient for most builds
    download-buffer-size = 268435456;
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable"; # pinned to 2.1.87, revert to "github:nixos/nixpkgs/nixos-unstable" once fixed
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    by-db = {
      url = "git+ssh://git@github.com/bebert64/perso?ref=SCIFO-wayland";
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
      nixpkgs-master,
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
      pkgsMaster = import nixpkgs-master {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      mkHost =
        {
          modules,
          extraSpecialArgs ? { },
        }:
        nixpkgs.lib.nixosSystem {
          inherit modules;
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

      homeConfigurations.monsters = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./home-manager/monsters.nix ];
        extraSpecialArgs = { inherit pkgsUnstable sops-nix; };
      };

      nixosConfigurations = {
        bureau = mkHost {
          modules = [ ./computers/bureau/configuration.nix ];
          extraSpecialArgs = { inherit by-db pkgsUnstable pkgsMaster; };
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
              pkgsMaster
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
              nixpkgs
              pkgsUnstable
              pkgsMaster
              sops-nix
              stockly-computers
              ;
          };
        };
      };
    };
}
