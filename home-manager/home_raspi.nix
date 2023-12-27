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
    direnv
    openssh
    openssl
    ranger
  ];

  home.file = {
    ".config/ranger/rc.conf".source = ../dotfiles/ranger/rc.conf;
    ".config/ranger/scope.sh".source = ../dotfiles/ranger/scope.sh;
  };

  # Session variable
  home.sessionVariables = {
    LC_ALL = "en_US.UTF-8";
  };
  
  # Activation script
  home.activation = {
    activationScript = ''
      # Symlink mount dir for NAS
      mkdir -p $HOME/mnt/
      ln -sf /mnt/NAS $HOME/mnt/

      # Symlink fonts
      ln -sf $HOME/nix-configs/fonts $HOME/.local/share/

      # Symlink btop config folder
      ln -sf $HOME/nix-configs/dotfiles/btop $HOME/.config

      # Create ranger's bookmarks
      mkdir -p $HOME/.local/share/ranger/
      sed "s/\$USER/"$USER"/" $HOME/nix-configs/dotfiles/ranger/bookmarks > $HOME/.local/share/ranger/bookmarks

      # Symlink some ssh config file
      # Do NOT symlink the whole dir, to make sure to never git private key
      mkdir -p $HOME/.ssh
      ln -sf $HOME/nix-configs/dotfiles/ssh/authorized_keys $HOME/.ssh/
      ln -sf $HOME/nix-configs/dotfiles/ssh/config $HOME/.ssh/
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
