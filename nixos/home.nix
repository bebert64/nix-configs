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
    jetbrains = (import ./programs/jetbrains.nix inputs);
  in
  [
    alock # locker allowing transparent background
    anydesk
    arandr # GUI to configure screens positions (need to kill autorandr)
    zip
    # avidemux # temporarily broken
    btop
    caffeine-ng # to prevent going to sleep when watching videos
    conky
    dconf # used for setting/loading gnome applications' settings (eg : tilix)
    direnv
    evince # pdf reader
    feh
    # fusee-interfacee-tk
    fusee-launcher
    gnome.gnome-calculator
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
    jmtpfs # to mount android devices
    jq # cli json processor, for some scripts (to get workspace id from i3)
    microcodeIntel # for increased microprocessor performance
    mcomix
    nodejs
    nodePackages.npm
    nodePackages.pnpm
    pavucontrol # pulse audio volume controle
    polybar
    postgresql
    qbittorrent
    qt6.qttools # needed to extract artUrl from strawberry and display it with conky
    rofi
    slack
    sqlite
    steam-run # needed to run custom binaries
    sshfs
    thunderbird-bin-unwrapped
    tilix # terminal
    udiskie
    unrar
    unzip
    vlc
    vscode
    xidlehook
    yt-dlp

    # imagemagick and scrot are used for image manipulation
    # to create the blur patches behind the conky widgets
    imagemagick
    scrot

    # Needed to mount Ipad
    ifuse
    libimobiledevice

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
    openssl

    # Strawberry
    strawberry
    playerctl # to send data and retrieve metadata for polybar

    # Test, to remove
    picom-next

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
    firefox = import ./programs/firefox.nix (pkgs);
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

  # Copy custom files / dotfiles
  home.file.".anydesk/user.conf".source = ../dotfiles/anydesk-user.conf;
  home.file.".config/polybar/colors.ini".source = ../dotfiles/polybar/colors.ini;
  home.file.".config/polybar/modules.ini".source = ../dotfiles/polybar/modules.ini;
  home.file.".config/polybar/config.ini".source = host-specific.polybar_config;
  home.file.".config/qt5ct/qt5ct.conf".source = ../dotfiles/qt5ct.conf;
  home.file.".config/ranger/rc.conf".source = ../dotfiles/ranger/rc.conf;
  home.file.".config/ranger/scope.sh".source = ../dotfiles/ranger/scope.sh;
  home.file.".config/rofi/theme".source = ../dotfiles/rofi/theme;
  home.file.".conky".source = ../dotfiles/conky;
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
    WALLPAPERS_DIR = "$HOME/wallpapers";
  };

  xdg = { 
    enable = true;
    mimeApps = {
      enable = true;
      associations.added = {
        "text/html" = [ "firefox.desktop" ];
        "text/xml" = [ "firefox.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
        "defaut-web-browser" = [ "firefox.desktop" ];
      };
      defaultApplications = {
        "text/html" = [ "firefox.desktop" ];
        "text/xml" = [ "firefox.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
        "defaut-web-browser" = [ "firefox.desktop" ];
      };
    };
  };

  # Activation script
  home.activation = {
    createDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p $HOME/mnt/Ipad/SideBooks $HOME/mnt/Ipad/Chunky $HOME/mnt/Ipad/MangaStorm
      ln -sf /mnt/NAS $HOME/mnt/
      rm -f $HOME/mnt/Usb-drives
      ln -sf /run/media/romain/ $HOME/mnt/Usb-drives
      ln -sf $HOME/configs/fonts $HOME/.local/share/

      # load terminal theme
      ${pkgs.dconf}/bin/dconf load /com/gexperts/Tilix/ < /home/romain/nix-configs/dotfiles/tilix.dconf

      # Symlink btop config folder
      ln -sf $HOME/nix-configs/dotfiles/btop $HOME/.config
      
      # Create ranger's bookmarks
      mkdir -p $HOME/.local/share/ranger/
      sed "s/\$USER/"$USER"/" $HOME/nix-configs/dotfiles/ranger/bookmarks > $HOME/.local/share/ranger/bookmarks
    '';
  };

  # General settings
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true; # Necessary for vscode
  home.stateVersion = "22.05";
}
