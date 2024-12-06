{
  description = "NixOS and HomeManager configurations";

  inputs = {
    stockly-computers.url = "git+ssh://git@github.com/Stockly/Computers.git";
    nixpkgs.follows = "stockly-computers/nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    by-db = {
      url = "git+ssh://git@github.com/bebert64/perso?ref=escapucina";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      by-db,
      stockly-computers,
      sops-nix,
      vscode-server,
      ...
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
            inherit
              home-manager
              by-db
              sops-nix
              vscode-server
              nixpkgs
              ;
          };
        };
      };
    };
}
