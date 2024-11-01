{
  pkgs,
  lib,
  by-db,
  host-specific,
  ...
}@inputs:
let
  scripts-playerctl = import ../scripts/playerctl.nix { inherit pkgs lib; };
  by-db-pkgs = by-db.packages.x86_64-linux;
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = host-specific.username;
  home.homeDirectory = "/home/${host-specific.username}";

  home.packages =
    let
      jetbrains = (import ../programs/jetbrains.nix inputs);
    in
    with pkgs;
    with gnome;
    [
      by-db-pkgs.wallpapers-manager
      anydesk
      arandr # GUI to configure screens positions (need to kill autorandr)
      avidemux
      caffeine-ng # to prevent going to sleep when watching videos
      # chromium
      conky
      direnv
      evince # pdf reader
      feh
      fusee-launcher
      gnome-calculator
      gnome-keyring
      # hicolor-icon-theme
      inkscape
      (callPackage ../programs/insomnia.nix { })
      jetbrains.datagrip
      jq # cli json processor, for some scripts (to get workspace id from i3)
      microcodeIntel # for increased microprocessor performance
      mcomix
      nixd
      nixfmt-rfc-style
      nodejs
      nodePackages.npm
      nodePackages.pnpm
      openssh
      openssl
      pavucontrol # pulse audio volume controle
      playerctl # to send data and retrieve metadata for polybar
      polkit # polkit is the utility used by vscode to save as sudo
      polkit_gnome
      # postgresql  # Check if really needed, as we now intall postgresql-libs through yay
      pulseaudio
      qt6.qttools # needed to extract artUrl from strawberry and display it with conky
      rofi
      rsync
      slack
      sqlite
      sshfs
      strawberry
      thunderbird-bin-unwrapped
      tilix # terminal
      udiskie
      unrar
      unzip
      vdhcoapp # companion to VideoDownloadHelper browser add-on
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

      # Theme for QT applications (vlc, strawberry...)
      qt5ct
      libsForQt5.qtstyleplugins

      # Ranger
      ranger
      ffmpegthumbnailer # thumbnail for videos preview
      fontforge # thumbnail for fonts preview
      poppler_utils # thumbnail for pdf preview

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
    ++ (
      if host-specific.nixos or false then
        [

          alock # locker allowing transparent background
          picom-next
        ]
      else
        [ ]
    )
    ++ import ../scripts { inherit host-specific pkgs; }
    ++ lib.attrsets.attrValues scripts-playerctl
    ++ (
      if host-specific.wifi or false then
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

  systemd.user = {
    enable = true;
    services = {
      wallpapers-manager = {
        Unit = {
          Description = "Chooses walpaper(s) based on the number of monitors connected";
        };
        Service = {
          Type = "exec";
          ExecStart = "${by-db-pkgs.wallpapers-manager}/bin/wallpapers-manager change --mode fifty-fifty";
        };

      };
    };
    timers = {
      wallpapers-manager = {
        Unit = {
          Description = "Timer for wallpapers-manager";
        };
        Timer = {
          Unit = "wallpapers-manager.service";
          OnUnitInactiveSec = "1h";
          OnBootSec = "1";
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };

      };
    };
  };

  # Copy custom files / dotfiles
  home.file = {
    ".anydesk/user.conf".source = ../../dotfiles/anydesk-user.conf;
    ".cargo/config.toml".source = ../../dotfiles/cargo_config.toml;
    ".config/qt5ct/qt5ct.conf".source = ../../dotfiles/qt5ct.conf;
    ".config/ranger/rc.conf".source = ../../dotfiles/ranger/rc.conf;
    ".config/ranger/scope.sh".source = ../../dotfiles/ranger/scope.sh;
    ".config/rofi/theme".source = ../../dotfiles/rofi/theme;
    ".conky".source = ../../dotfiles/conky;
    ".vscode/extensions/stockly.monokai-stockly-1.0.0".source = ../../dotfiles/MonokaiStockly;
    ".themes".source = "${pkgs.palenight-theme}/share/themes";
    ".xinitrc".source = ../../dotfiles/.xinitrc;
  };

  home.pointerCursor = {
    x11.enable = true;
    package = pkgs.gnome.adwaita-icon-theme;
    name = "Adwaita";
    size = 32;
  };

  # launch i3
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

  fonts.fontconfig.enable = true;

  # Session variable
  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt5ct";
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
    createDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Create mount dirs
      ln -sf /mnt/NAS $HOME/mnt/
      ln -sf -T /run/media/romain ~/mnt/usb

      # Symlink fonts
      ln -sf $HOME/nix-configs/fonts $HOME/.local/share/

      # Symlink picom config file
      ln -sf $HOME/nix-configs/dotfiles/picom.conf $HOME/.config

      # load terminal theme
      ${pkgs.dconf}/bin/dconf load /com/gexperts/Tilix/ < ${../../dotfiles/tilix.dconf}

      # Create ranger's bookmarks
      mkdir -p $HOME/.local/share/ranger/
      sed "s/\$USER/"$USER"/" $HOME/nix-configs/dotfiles/ranger/bookmarks > $HOME/.local/share/ranger/bookmarks

      # Datagrip
      ln -sf $HOME/nix-configs/dotfiles/Datagrip/DataGripProjects $HOME

      # Symlink some ssh config file
      # Do NOT symlink the whole dir, to make sure to never git private key
      mkdir -p $HOME/.ssh
      ln -sf $HOME/nix-configs/dotfiles/ssh/authorized_keys $HOME/.ssh/
    '';
  };

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true; # Necessary for vscode

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.
}
