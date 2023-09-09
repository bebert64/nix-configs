{ config, pkgs, lib, config-name, host-specifics, ... }@inputs:

let
  monoFont = "DejaVu Sans Mono";
  args = ({ inherit monoFont; } // inputs);
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "romain";
  home.homeDirectory = "/home/romain";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs;
  let
    polybar = pkgs.polybar.override {
      i3Support = true;
      pulseSupport = true;
    };
  in [
    alock # locker allowing transparent background
    anydesk
    arandr # GUI to configure screens positions (need to kill autorandr)
    avidemux
    btop
    caffeine-ng # to prevent going to sleep when watching videos
    conky
    dconf # used for setting/loading gnome applications' settings (eg : tilix)
    direnv
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
    mcomix
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
    openssh
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
    zip

    # imagemagick and scrot are used for image manipulation
    # to create the blur patches behind the conky widgets
    imagemagick
    scrot

    # Needed to mount Ipad
    ifuse
    libimobiledevice

    # polkit is the utility used by vscode to save as sudo
    # polkit
    # polkit_gnome

    # Theme for QT applications (vlc, strawberry...)
    qt5ct
    libsForQt5.qtstyleplugins

    # Ranger
    ranger
    ffmpegthumbnailer # thumbnail for videos preview
    fontforge # thumbnail for fonts preview
    poppler_utils # thumbnail for pdf preview

    # Rust
    # rustup
    # pkg-config
    # gcc
    openssl

    # Strawberry
    strawberry
    playerctl # to send data and retrieve metadata for polybar

    # Test, to remove
    picom-next
  ]++ import ./scripts.nix host-specifics pkgs ++ (
    if host-specifics.wifi then
      [
        networkmanager
        networkmanagerapplet
      ] else []
    );


  # Programs known by Home-Manager
  programs = {
    autorandr = host-specifics.autorandr;
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
    zsh = import ./programs/zsh.nix ( { inherit config-name; });
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".anydesk/user.conf".source = ../dotfiles/anydesk-user.conf;
    ".config/btop/btop.conf".source = ../dotfiles/btop.conf;
    ".config/polybar/colors.ini".source = ../dotfiles/polybar/colors.ini;
    ".config/polybar/modules.ini".source = ../dotfiles/polybar/modules.ini;
    ".config/polybar/config.ini".source = host-specifics.polybar_config;
    ".config/qt5ct/qt5ct.conf".source = ../dotfiles/qt5ct.conf;
    ".config/oh-my-zsh-scripts/git.zsh".source = ../dotfiles/OhMyZsh/git.zsh;
    ".config/ranger/rc.conf".source = ../dotfiles/ranger/rc.conf;
    ".config/ranger/scope.sh".source = ../dotfiles/ranger/scope.sh;
    ".config/rofi/theme".source = ../dotfiles/rofi/theme;
    ".conky".source = ../dotfiles/conky;
    ".local/share/ranger/bookmarks".source = ../dotfiles/ranger/bookmarks;
    ".tilix.dconf".source = ../dotfiles/tilix.dconf;
    ".vscode/extensions/stockly.monokai-stockly-1.0.0".source = ../dotfiles/MonokaiStockly;
  };

  # launch i3
  xsession.windowManager.i3 = import ./programs/i3.nix (args);
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

  xdg.mimeApps = {
    enable = true;
    associations.added = {
      "default-web-browser" = ["firefox.desktop"];
    };
    defaultApplications = {
      "default-web-browser" = ["firefox.desktop"];
    };
  };

  # Activation script
  home.activation = {
    createDirs = ''
      mkdir -p $HOME/Mnt/Cluster/fixe-bureau $HOME/Mnt/Cluster/fixe-salon $HOME/Mnt/Cluster/stockly-romainc $HOME/Mnt/Cluster/raspy
      mkdir -p $HOME/Mnt/Charybdis
      mkdir -p $HOME/Mnt/Ipad/SideBooks $HOME/Mnt/Ipad/Chunky $HOME/Mnt/Ipad/MangaStorm
      ln -sf /mnt/NAS $HOME/Mnt/
      rm -f $HOME/Mnt/Usb-drives
      ln -sf /run/media/romain/ $HOME/Mnt/Usb-drives
      ln -sf $HOME/nix-configs/fonts $HOME/.local/share/

      # load terminal theme
      # dconf load /com/gexperts/Tilix/ < /home/romain/.tilix.dconf
    '';
  };
  
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true; # Necessary for vscode and anydesk
}
