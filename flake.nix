{
  description = "NixOS and HomeManager configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/";
    stockly-computers = {
      url = "git+ssh://git@github.com/Stockly/Computers.git";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixpkgs.follows = "stockly-computers/nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    by-db = {
      url = "git+ssh://git@github.com/bebert64/perso";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "github:Ten0/nixos-vscode-server";
      inputs.nixpkgs.follows = "stockly-computers/nixpkgs";
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
          modules = [
            ./fixe-bureau/configuration.nix
          ];
          specialArgs = {
            inherit
              home-manager
              by-db
              sops-nix
              stockly-computers
              vscode-server
              ;
          };
        };
      };

      homeConfigurations = {
        raspi = home-manager.lib.homeManagerConfiguration rec {
          pkgs = import nixpkgs { system = "aarch64-linux"; };
          modules = [ (import ./raspi/home_raspi.nix { inherit pkgs; }) ];
        };
      };
    };
}
