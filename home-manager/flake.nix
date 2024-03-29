{
  description = "Home-manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }: 
    let 
      raspi = "raspi";
      fixe-bureau = "fixe-bureau";
      config = {
        allowUnfree = true;
      };
    in {
      homeConfigurations = {
        ${raspi} = home-manager.lib.homeManagerConfiguration rec {
          pkgs = import nixpkgs {
            system = "aarch64-linux";  # x86_64-linux, aarch64-multiplatform, etc.
            inherit config;
          };

          modules = [
            (import ./home_raspi.nix ( { config-name = raspi; inherit pkgs; }))
          ];
        };

        ${fixe-bureau} = home-manager.lib.homeManagerConfiguration rec {
          pkgs = import nixpkgs {
            system = "x86_64-linux";  # x86_64-linux, aarch64-multiplatform, etc.
            inherit config;
          };

          modules = 
            let
              host-specifics = import ./fixe-bureau/host_specifics.nix;
            in [
              (import ./home.nix ( { 
                config-name = fixe-bureau; 
                inherit pkgs config host-specifics; 
                lib=nixpkgs.lib; 
                hm-lib=home-manager.lib;
              }))
            ];
        };
      };
  };
    
}
