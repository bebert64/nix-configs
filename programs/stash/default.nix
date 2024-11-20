{ nixpkgs-unstable, pkgs, ... }:
let
  overlay-unstable = final: prev: {
    unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
  };
in
{
  home.packages = [ pkgs.unstable.stash ];

  nixpkgs.overlays = [ overlay-unstable ];
}
