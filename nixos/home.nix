host-specific: { pkgs, lib, ... }@inputs:

let
  monoFont = "DejaVu Sans Mono";
  args = ({ inherit monoFont; } // inputs);
in
{

  # Packages Home-Manager doesn't have specific handling for
  home.packages = with pkgs; 
  let
    polybar = pkgs.polybar.override {
      i3Support = true;
      pulseSupport = true;
    };
  in
  [
    alock # locker allowing transparent background
    anydesk
    arandr # GUI to configure screens positions (need to kill autorandr)
    avidemux
    btop
    caffeine-ng # to prevent going to sleep when watching videos
    conky
    dconf # used for setting/loading gnome applications' settings (eg : tilix)
    evince # pdf reader
    feh
    firefox-bin-unwrapped
    gnome.gnome-keyring
    grsync # check if rsync needed in addition
    ifuse # mount apple's file system (Ipad)
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
    jq # cli json processor, for some scripts (to get workspace id from i3)
    microcodeIntel # for increased microprocessor performance
    nodejs
    nodePackages.npm
    pavucontrol # pulse audio volume controle
    polybar
    qbittorrent
    rofi
    slack
    sqlite
    steam-run # needed to run custom binaries
    sshfs
    thunderbird-bin-unwrapped
    tilix # terminal
    udiskie # automount usb keys and drives
    unrar
    unzip
    vlc
    vscode
    xidlehook
    yt-dlp

    # polkit is the utility used by vscode to save as sudo
    polkit
    polkit_gnome

    # Theme for QT applications (vlc, strawberry...)
    qt5ct
    libsForQt5.qtstyleplugins

    # Ranger
    ranger
    ffmpegthumbnailer # thumbnail for videos preview
    fontforge # thumbnail for fonts preview
    poppler_utils # thumbnail for pdf preview

    # Rust
    rustup
    pkg-config
    gcc

    # Strawberry
    strawberry
    playerctl # to send data and retrieve metadata for polybar

  ] ++ import ./scripts.nix host-specific pkgs ++ (
    if host-specific.wifi then 
      [
        networkmanager
        networkmanagerapplet
      ] else []
    );


  # Programs known by Home-Manager
  programs = {
    autorandr = host-specific.autorandr;
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
    picom = {
      enable = true;
      settings = {
        corner-radius = 10;
        rounded-corners-exclude = [
           "window_type = 'dock'"
        ];
      };
    };
  };

  # Copy custom files / dotfiles
  home.file.".anydesk/user.conf".source = ../dotfiles/anydesk-user.conf;
  home.file.".config/btop/btop.conf".source = ../dotfiles/btop.conf;
  home.file.".config/polybar/colors.ini".source = ../dotfiles/polybar/colors.ini;
  home.file.".config/polybar/modules.ini".source = ../dotfiles/polybar/modules.ini;
  home.file.".config/polybar/config.ini".source = host-specific.polybar_config;
  home.file.".config/qt5ct/qt5ct.conf".source = ../dotfiles/qt5ct.conf;
  home.file.".config/oh-my-zsh-scripts/git.zsh".source = ../dotfiles/OhMyZsh/git.zsh;
  home.file.".config/ranger/rc.conf".source = ../dotfiles/ranger/rc.conf;
  home.file.".config/ranger/scope.sh".source = ../dotfiles/ranger/scope.sh;
  home.file.".config/rofi/theme".source = ../dotfiles/rofi/theme;
  home.file.".conky/qclocktwo".source = ../dotfiles/conky/qclocktwo;
  home.file.".conky/conky-grapes".source = ../dotfiles/conky/conky-grapes;
  home.file.".local/share/ranger/bookmarks".source = ../dotfiles/ranger/bookmarks;
  home.file.".tilix.dconf".source = ../dotfiles/tilix.dconf;
  home.file.".vscode/extensions/stockly.monokai-stockly-1.0.0".source = ../dotfiles/MonokaiStockly;

  # X Config
  xsession = {
    enable = true;
    scriptPath = ".hm-xsession";
    windowManager.i3 = import ./programs/i3.nix (args // { host-specific = host-specific; });
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
