host-specific:
{ pkgs, lib, ... }@inputs:

let
  scripts-playerctl = import ../scripts-playerctl.nix { inherit pkgs lib; };
in

{

  # Packages Home-Manager doesn't have specific handling for
  home.packages =
    let
      jetbrains = (import ../programs/jetbrains.nix inputs);
    in
    with pkgs;
    with gnome;
    [
      alock # locker allowing transparent background
      anydesk
      arandr # GUI to configure screens positions (need to kill autorandr)
      avidemux
      caffeine-ng # to prevent going to sleep when watching videos
      chromium
      conky
      dconf # used for setting/loading gnome applications' settings (eg : tilix)
      direnv
      evince # pdf reader
      feh
      # fusee-interfacee-tk
      fusee-launcher
      gnome-calculator
      gnome-keyring
      grsync # check if rsync needed in addition
      inkscape
      (callPackage ../programs/insomnia.nix { })
      jetbrains.datagrip
      jmtpfs # to mount android devices
      jq # cli json processor, for some scripts (to get workspace id from i3)
      microcodeIntel # for increased microprocessor performance
      mcomix
      nixd
      nixfmt-rfc-style
      nodejs
      nodePackages.npm
      nodePackages.pnpm
      pavucontrol # pulse audio volume controle
      playerctl # to send data and retrieve metadata for polybar
      postgresql
      pulseaudio
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
      xclip # used by ranger to paste into global clipboard
      xidlehook
      yt-dlp
      zip

      # imagemagick and scrot are used for image manipulation
      # to create the blur patches behind the conky widgets
      imagemagick
      scrot

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

      # fonts
      dejavu_fonts
      fira-code
      font-awesome
      font-awesome_4
      font-awesome_5
      helvetica-neue-lt-std
      liberation_ttf_v1
      (nerdfonts.override {
        fonts = [
          "FiraCode"
          "Iosevka"
        ];
      })
      noto-fonts
      noto-fonts-emoji
      powerline-fonts

    ]
    ++ import ../scripts.nix { inherit host-specific pkgs; }
    ++ lib.attrsets.attrValues scripts-playerctl
    ++ (
      if host-specific.wifi then
        [
          networkmanager
          networkmanagerapplet
        ]
      else
        [ ]
    );

  # Programs known by Home-Manager
  programs = {
    autorandr = host-specific.autorandr;
    btop = import ../programs/btop.nix;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };
    firefox = import ../programs/firefox.nix;
    git = import ../programs/git.nix;
    ssh = import ../programs/ssh/default.nix;
    vim = {
      extraConfig = ''
        set autoindent
        set number
        syntax on
      '';
    };
    zsh = import ../programs/zsh.nix { additional-aliases = host-specific.zsh-aliases or { }; };
  };

  services = {
    polybar = import ../programs/polybar/default.nix { inherit pkgs scripts-playerctl; };
    playerctld = {
      enable = true;
    };
  };

  # Copy custom files / dotfiles
  home.file.".anydesk/user.conf".source = ../../dotfiles/anydesk-user.conf;
  home.file.".config/qt5ct/qt5ct.conf".source = ../../dotfiles/qt5ct.conf;
  home.file.".config/ranger/rc.conf".source = ../../dotfiles/ranger/rc.conf;
  home.file.".config/ranger/scope.sh".source = ../../dotfiles/ranger/scope.sh;
  home.file.".config/rofi/theme".source = ../../dotfiles/rofi/theme;
  home.file.".conky".source = ../../dotfiles/conky;
  home.file.".vscode/extensions/stockly.monokai-stockly-1.0.0".source = ../../dotfiles/MonokaiStockly;

  # X Config
  xsession = {
    enable = true;
    scriptPath = ".hm-xsession";
    windowManager.i3 = import ../programs/i3.nix { inherit lib host-specific; };
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
    createDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ln -sf /mnt/NAS $HOME/mnt/
      rm -f $HOME/mnt/Usb-drives
      ln -sf /run/media/romain/ $HOME/mnt/Usb-drives
      ln -sf $HOME/configs/fonts $HOME/.local/share/

      # load terminal theme
      ${pkgs.dconf}/bin/dconf load /com/gexperts/Tilix/ < ${../../dotfiles/tilix.dconf}

      # Create ranger's bookmarks
      mkdir -p $HOME/.local/share/ranger/
      sed "s/\$USER/"$USER"/" ${../../dotfiles/ranger/bookmarks} > $HOME/.local/share/ranger/bookmarks
    '';
  };

  # General settings
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true; # Necessary for vscode
  home.stateVersion = "22.05";
}
