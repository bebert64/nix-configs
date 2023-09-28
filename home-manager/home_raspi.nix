{ config-name, pkgs } :

{
  home = {
    homeDirectory = "/home/romain";
    username = "romain";
    stateVersion = "23.05";
  };

  home.packages = with pkgs;
  [
    btop
    certbot  # CLI to get certificates from Let's Encrypt
    direnv
    ranger
  ];

  home.file = {
    ".config/ranger/rc.conf".source = ../dotfiles/ranger/rc.conf;
    ".config/ranger/scope.sh".source = ../dotfiles/ranger/scope.sh;
  };
  
  # Activation script
  home.activation = {
    rangerBookmarks = ''
      sed "s/\$USER/"$USER"/"  $HOME/nix-configs/dotfiles/ranger/bookmarks > $HOME/nix-configs/ranger_bookmarks
      mkdir -p $HOME/.local/share/ranger/
      ln -sf $HOME/nix-configs/ranger_bookmarks $HOME/.local/share/ranger/bookmarks
    '';
  };

  nixpkgs = {
    config = {
      system = "aarch64-linux";  # x86_64-linux, aarch64-multiplatform, etc.
      allowUnfree = true;
    };
  };

  programs = {
    zsh = import ./programs/zsh.nix ( { config-name = "raspi"; });
    git = import ./programs/git.nix;
    home-manager.enable = true;
  };
  
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

}
