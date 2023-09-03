
{
  home = {
        homeDirectory = "/home/DonBeberto";
        username = "DonBeberto"; # $USER
        stateVersion = "23.05";     # See https://nixos.org/manual/nixpkgs/stable for most recent
  };

  nixpkgs = {
    config = {
        system = "aarch64-linux";  # x86_64-linux, aarch64-multiplatform, etc.
      allowUnfree = true;
      # allowUnsupportedSystem = true;
      # experimental-features = "nix-command flakes";
    };
  };

  programs = {
    zsh = import ./programs/zsh.nix;
    home-manager.enable = true;
  };
}
