host-specific: { pkgs, lib, ... }@inputs:

let
  monoFont = "DejaVu Sans Mono";
  args = ({ inherit monoFont; } // inputs);
in
{
  
  # Packages Home-Manager doesn't have specific handling for
  home.packages = with pkgs; [
    anydesk
    arandr # GUI to configure screens positions (need to kill autorandr)
    avidemux
    btop
    caffeine-ng # to prevent going to sleep when watching videos
    dconf # used for gnome settings
    feh
    gnome.gnome-keyring
    gnome.gnome-terminal
    grsync # check if rsync needed in addition
    inkscape
    (insomnia.overrideAttrs (oldAttrs: rec {
      pname = "insomnia-stockly";
      version = "2022.7.0";
      src = fetchurl {
        url = "https://stockly-public-assets.s3.eu-west-1.amazonaws.com/Insomnia.Core-2022.7.0-patched.deb";
        sha256 = "sha256-6abpLq1ykAfn7ag5hY2Y6e53kx7svkSb+7OdWSDRLbE=";
      };
    }))
    jetbrains.datagrip
    microcodeIntel # for increased microprocessor performance
    nodejs
    nodePackages.npm
    pavucontrol
    # polkit is the utility used by vscode to save as sudo
    polkit
    polkit_gnome
    ranger
    rofi
    slack
    sshfs
    tilix # save config in nixos-configs and symlink to it...
    unrar
    vlc
    yt-dlp
  ];


  # Programs known by Home-Manager
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };
    git = import ./programs/git.nix;
    # gnome-terminal = {
    #   profile.transparencyPercent = 8;
    # };
  };

  # Services
  services = {
    picom.enable = true;
  };

  # Copy custom files
  home.file."`~/.vscode/extensions/stockly.monokai-stockly-1.0.0".source = ./MonokaiStockly;

  # X Config
  xsession = {
    enable = true;
    scriptPath = ".hm-xsession";
    windowManager.i3 = import ./programs/i3.nix (args// { host-specific = host-specific.i3 args; });
    numlock.enable = true;
  };
  gtk = {
    enable = true;
    theme = {
      package = pkgs.gnome.gnome-themes-extra;
      name = "Adwaita-dark";
    };
  };

  # General settings
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true; # Necessary for vscode
  home.stateVersion = "22.05";
}
