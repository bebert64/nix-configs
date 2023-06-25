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
    jq # cli json processor, for some scripts (to get workspace id from i3)
    microcodeIntel # for increased microprocessor performance
    nodejs
    nodePackages.npm
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
    libpqxx
    # openssl.dev
    # libiconv
    # pkgconfig

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
    # picom-jonaburg = {
    #   enable = true;
    #   settings = {
    #     corner-radius = 10;
    #     rounded-corners-exclude = [
    #        "window_type = 'dock'"
    #     ];
    #     # backend = "glx";
            
    #   };
    # };
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
  home.file.".conky".source = ../dotfiles/conky;
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
    XDG_DATA_HOME   = "$HOME/.local/share";
  };

  # Activation script
  home.activation = {
    createDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p $HOME/Mnt/Cluster/fixe-bureau $HOME/Mnt/Cluster/fixe-salon $HOME/Mnt/Cluster/stockly-romainc $HOME/Mnt/Cluster/raspy
      mkdir -p $HOME/Mnt/Charybdis
      mkdir -p $HOME/Mnt/Ipad/SideBooks $HOME/Mnt/Ipad/Chunky $HOME/Mnt/Ipad/MangaStorm
      ln -sf /mnt/NAS $HOME/Mnt/
      rm -f $HOME/Mnt/Usb-drives
      ln -sf /run/media/romain $HOME/Mnt/Usb-drives
      ln -sf $HOME/configs/fonts $HOME/.local/share/

      # load terminal theme
      dconf load /com/gexperts/Tilix/ < /home/romain/.tilix.dconf
    '';
  };

  # General settings
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true; # Necessary for vscode
  home.stateVersion = "22.05";
}
