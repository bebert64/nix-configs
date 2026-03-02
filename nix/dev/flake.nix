{
  description = "nix-configs dev shell (nixfmt, nixd, etc.)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          name = "nix-configs";
          nativeBuildInputs = with pkgs; [
            nixd
            nixfmt-rfc-style
          ];
        };
      }
    );
}
