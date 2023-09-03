{ homeDirectory
, pkgs
, stateVersion
, system
, username }:

{
  home = {
    inherit homeDirectory stateVersion username;
  };

  nixpkgs = {
    config = {
      inherit system;
      allowUnfree = true;
      allowUnsupportedSystem = true;
      experimental-features = "nix-command flakes";
    };
  };

  programs = {
    zsh = import ./programs/zsh.nix;
    home-manager.enable = true;
  };
}
