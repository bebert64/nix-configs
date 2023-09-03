{
  description = "Home-manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }: {
    homeConfigurations = {
      raspyDB = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-linux";  # x86_64-linux, aarch64-multiplatform, etc.
          config = {
            allowUnfree = true;
          };
        };

        modules = [
          (import ./home_raspy.nix)
        ];
      };
    };

  };
    
}
