{ config, pkgs, lib, hm-lib, config-name, host-specifics, ... }@inputs:

let
  monoFont = "DejaVu Sans Mono";
  args = ({ inherit monoFont; } // inputs);
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "romain";
  home.homeDirectory = "/home/romain";

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs;
  let
    polybar = pkgs.polybar.override {
      i3Support = true;
      pulseSupport = true;
    };
    jetbrains = (import ./programs/jetbrains.nix inputs);
  in [
    anydesk
    arandr # GUI to configure screens positions (need to kill autorandr)
    avidemux
    btop
    caffeine-ng # to prevent going to sleep when watching videos
    conky
    direnv
    evince # pdf reader
    feh
    firefox-bin-unwrapped
    gnome.gnome-calculator
    gnome.gnome-keyring
    hicolor-icon-theme
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
    picom-next
    polybar
    postgresql
    qt6.qttools # needed to extract artUrl from strawberry and display it with conky
    rofi
    rsync grsync # (= graphical rsync)
    slack
    sqlite
    openssh
    openssl
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

    # Theme for QT applications (vlc, strawberry...)
    qt5ct
    libsForQt5.qtstyleplugins

    # Ranger
    ranger
    ffmpegthumbnailer # thumbnail for videos preview
    fontforge # thumbnail for fonts preview
    poppler_utils # thumbnail for pdf preview

    # Strawberry
    strawberry
    playerctl # to send data and retrieve metadata for polybarw

    # fonts
    noto-fonts
    noto-fonts-emoji
    dejavu_fonts
    liberation_ttf_v1
    helvetica-neue-lt-std

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
    firefox = import ./programs/firefox.nix;
    git = import ./programs/git.nix;
    thunderbird = import ./programs/thunderbird.nix;
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
    ".cargo/config.toml".source = ../dotfiles/cargo_config.toml;
    ".config/btop/btop.conf".source = ../dotfiles/btop.conf;
    ".config/polybar/colors.ini".source = ../dotfiles/polybar/colors.ini;
    ".config/polybar/modules.ini".source = ../dotfiles/polybar/modules.ini;
    ".config/polybar/config.ini".source = host-specifics.polybar_config;
    ".config/qt5ct/qt5ct.conf".source = ../dotfiles/qt5ct.conf;
    ".config/ranger/rc.conf".source = ../dotfiles/ranger/rc.conf;
    ".config/ranger/scope.sh".source = ../dotfiles/ranger/scope.sh;
    ".config/rofi/theme".source = ../dotfiles/rofi/theme;
    ".conky".source = ../dotfiles/conky;
    ".vscode/extensions/stockly.monokai-stockly-1.0.0".source = ../dotfiles/MonokaiStockly;
    ".themes".source = "${pkgs.palenight-theme}/share/themes";
    ".xinitrc".source = ../dotfiles/.xinitrc;
  };

  home.pointerCursor = {
      x11.enable = true;
      package = pkgs.gnome3.adwaita-icon-theme;
      name = "Adwaita";
      size = 32;
  };

  # launch i3
  xsession = {
    enable = true;
    windowManager.i3 = import ./programs/i3.nix (args);
    numlock.enable = true;
  };
  gtk = {
    enable = true;
    theme = {
      name = "palenight";
      package = pkgs.palenight-theme;
    };
  };

  fonts.fontconfig.enable = true;

  # Session variable
  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt5ct";
    WALLPAPERS_DIR = "$HOME/Wallpapers";
    XDG_DATA_DIRS = "$HOME/.nix-profile/share:/usr/local/share:/usr/share:$HOME/.local/share";
    LC_ALL = "en_US.UTF-8";
  };

  xdg = { 
    enable = true;
    mimeApps = {
      enable = true;
      associations.added = {
        "defaut-web-browser" = [ "firefox.desktop" ];
        "text/html" = [ "firefox.desktop" ];
        "text/xml" = [ "firefox.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
      };
      defaultApplications = {
        "defaut-web-browser" = [ "firefox.desktop" ];
        "text/html" = [ "firefox.desktop" ];
        "text/xml" = [ "firefox.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
      };
    };
  };

  # Activation script
  home.activation = {
    createDirs = hm-lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p $HOME/mnt/Ipad/SideBooks $HOME/mnt/Ipad/Chunky $HOME/mnt/Ipad/MangaStorm
      ln -sf /mnt/NAS $HOME/mnt/
      ln -sf -T /run/media/romain ~/mnt/usb 
      ln -sf $HOME/nix-configs/fonts $HOME/.local/share/

      # load terminal theme
      ${pkgs.dconf}/bin/dconf load /com/gexperts/Tilix/ < /home/romain/nix-configs/dotfiles/tilix.dconf

      # Create ranger's bookmarks
      mkdir -p $HOME/.local/share/ranger/
      sed "s/\$USER/"$USER"/" $HOME/nix-configs/dotfiles/ranger/bookmarks > $HOME/.local/share/ranger/bookmarks

      # Datagrip
      ln -sf $HOME/nix-configs/dotfiles/Datagrip/DataGripProjects $HOME
    '';
  };

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true; # Necessary for vscode and anydesk

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.
}
