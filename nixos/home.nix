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
    evince # pdf reader
    feh
    firefox
    gnome.gnome-keyring
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
    killall # for some reason, not included by default
    microcodeIntel # for increased microprocessor performance
    nodejs
    nodePackages.npm
    pavucontrol # pulse audio volume controle
    # polkit is the utility used by vscode to save as sudo
    polkit
    polkit_gnome
    # Theme for QT applications (vlc, strawberry...)
    qt5ct
    libsForQt5.qtstyleplugins
    ranger
    rofi
    slack
    sqlite
    steam-run # needed to run custom binaries
    strawberry
    sshfs
    tilix # terminal
    unrar
    vlc
    vscode
    yt-dlp

    # Rust
    rustup
    gcc
    # cmake
  ];


  # Programs known by Home-Manager
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };
    git = import ./programs/git.nix;
    vim = {
      extraConfig = ''
        set autoindent
        set number
        syntax on
      '';
    };
    zsh = import ./programs/zsh.nix;
  };

  # Services
  services = {
    picom.enable = true;
  };

  # Copy custom files / dotfiles
  home.file.".config/qt5ct/qt5ct.conf".source = ../dotfiles/qt5ct.conf;
  home.file.".ssh/config".source = ../dotfiles/ssh_config;
  home.file.".vscode/extensions/stockly.monokai-stockly-1.0.0".source = ../plugins/MonokaiStockly;
  home.file."scripts/strawberry".source = ../plugins/strawberry_script;
  home.file.".envrc".source = ../dotfiles/.envrc;

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
      name = "palenight";
      package = pkgs.palenight-theme;
    };
  };

  # Session variable
  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt5ct";
  };

  # General settings
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true; # Necessary for vscode
  home.stateVersion = "22.05";
}
