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
      config = {
        allowUnfree = true;
      };
    in {
      homeConfigurations = {
        ${raspy} = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "aarch64-linux";  # x86_64-linux, aarch64-multiplatform, etc.
            inherit config;
          };

          modules = [
            (import ./home_raspy.nix ( { config_name = raspy; }))
          ];
        };

        "raspy2" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "x86_64-linux";  # x86_64-linux, aarch64-multiplatform, etc.
            config = {
              allowUnfree = true;
            };
          };

          modules = [
            (import ./home_raspy.nix ( { config_name = "raspy2"; }))
          ];
        };
      };
  };
    
}
