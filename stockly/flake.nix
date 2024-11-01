{
  description = "NixOS configurations merging Stockly's and mine";

  inputs = {
    stockly-computers.url = "git+ssh://git@github.com/Stockly/Computers.git";
    romain-computers = {
      url = "git+ssh://git@github.com/bebert64/nix-configs?ref=merge-home-nix";
      inputs.nixpkgs.follows = "stockly-computers/nixpkgs";
    };
  };

  outputs =
    { stockly-computers, romain-computers, ... }@inputs:
    let
      hostname = "stockly-romainc";
    in
    {
      nixosConfigurations.${hostname} = stockly-computers.personalComputers.stocklyNixosSystem {
        inherit hostname;
        configuration = ./configuration.nix;
        specialArgs = {
          inherit inputs;
        } // romain-computers.stockly-romainc.specialArgs;
      };
    };
}
