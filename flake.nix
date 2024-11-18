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
    sops-nix = {
      url = "github:Mic92/sops-nix?ref=d2bd7f433b28db6bc7ae03d5eca43564da0af054";
    };

  };

  outputs =
    { nixpkgs
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
      };

      homeConfigurations = {
        raspi = home-manager.lib.homeManagerConfiguration rec {
          pkgs = import nixpkgs { system = "aarch64-linux"; };
          modules = [ (import ./raspi/home_raspi.nix { inherit pkgs; }) ];
        };
      };
    };
}
