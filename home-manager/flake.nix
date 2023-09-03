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
      raspy = "raspy";
      fixe-bureau = "fixe-bureau";
      config = {
        allowUnfree = true;
      };
    in {
      homeConfigurations = {
        ${raspy} = home-manager.lib.homeManagerConfiguration rec {
          pkgs = import nixpkgs {
            system = "aarch64-linux";  # x86_64-linux, aarch64-multiplatform, etc.
            inherit config;
          };

          modules = [
            (import ./home_raspy.nix ( { config-name = raspy; inherit pkgs; }))
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
              (import ./home.nix ( { config-name = fixe-bureau; inherit pkgs config host-specifics; lib=nixpkgs.lib; }))
            ];
        };
      };
  };
    
}
