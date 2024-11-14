{
  pkgs,
  lib,
  by-db,
  config,
  ...
}@inputs:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (types) int str;
  inherit (pkgs) callPackage;
  inherit (by-db.packages.x86_64-linux) wallpapers-manager;
in
{
  options.by-db = {
    username = mkOption { type = str; };
    bluetooth.enable = mkEnableOption "Whether to activate or not the blueman applet";
    wifi.enable = mkEnableOption "Whether or not to install network manager";
    screens = {
      primary = mkOption {
        type = str;
        description = "The primary screen";
      };
      secondary = mkOption {
        type = str;
        description = "The secondary screen";
      };
    };
    minutes-before-lock = mkOption {
      type = int;
      default = 3;
      description = "Minutes before the computer locks itself";
    };
    minutes-from-lock-to-sleep = mkOption {
      type = int;
      default = 7;
      description = "Minutes from the moment the computer locks itself to the moment it starts sleeping";
    };
    setHeadphonesCommand = mkOption {
      type = str;
      description = "Command to redirect the sound output to headphones";
    };
    setSpeakerCommand = mkOption {
      type = str;
      description = "Command to redirect the sound output to speaker";
    };
  };

  imports = [
    ./scripts.nix
    ./programs/common-user.nix
  ];

  config =
    let
      cfg = config.by-db;
    in
    {

      home.username = "${cfg.username}";
      home.homeDirectory = "/home/${cfg.username}";

      home.packages =
        (with pkgs; [
          alock # locker allowing transparent background
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
          gnome.gnome-calculator
          gnome.gnome-keyring
          # hicolor-icon-theme
          inkscape
          jq # cli json processor, for some scripts (to get workspace id from i3)
          microcodeIntel # for increased microprocessor performance
          mcomix
          nixd
          nixfmt-rfc-style
          nixpkgs-fmt
          nodejs
          nodePackages.npm
          nodePackages.pnpm
          openssh
          pavucontrol # pulse audio volume controle
          picom-next
          playerctl # to send data and retrieve metadata for polybar
          polkit # polkit is the utility used by vscode to save as sudo
          polkit_gnome
          pulseaudio
          qt6.qttools # needed to extract artUrl from strawberry and display it with conky
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
          libsForQt5.qt5ct
          libsForQt5.qtstyleplugins

          # Ranger
          ranger
          ffmpegthumbnailer # thumbnail for videos preview
          fontforge # thumbnail for fonts preview
          poppler_utils # thumbnail for pdf preview

          # fonts
          (nerdfonts.override {
            fonts = [
              "FiraCode"
              "Iosevka"
            ];
          })
        ])
        ++ [
          (callPackage ./programs/insomnia.nix { })
          (import ./programs/jetbrains.nix inputs).datagrip
          wallpapers-manager
          (mkIf cfg.wifi.enable (
            with pkgs;
            [
              networkmanager
              networkmanagerapplet
            ]
          ))
        ];

      # Programs known by Home-Manager
      programs = {
        direnv = {
          enable = true;
          nix-direnv.enable = true;
          enableZshIntegration = true;
        };
        vim = {
          extraConfig = ''
            set autoindent
            set number
            syntax on
          '';
        };
      };

      services = {
        playerctld.enable = true;
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
              ExecStart = "${wallpapers-manager}/bin/wallpapers-manager change --mode fifty-fifty";
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

      # Copy custom files / assets
      home.file = {
        ".anydesk/user.conf".source = ./assets/anydesk-user.conf;
        ".cargo/config.toml".source = ./assets/cargo_config.toml;
        ".config/qt5ct/qt5ct.conf".source = ./assets/qt5ct.conf;
        ".config/ranger/rc.conf".source = ./assets/ranger/rc.conf;
        ".config/ranger/scope.sh".source = ./assets/ranger/scope.sh;
        ".conky".source = ./assets/conky;
        ".vscode/extensions/stockly.monokai-stockly-1.0.0".source = ./assets/MonokaiStockly;
        ".themes".source = "${pkgs.palenight-theme}/share/themes";
        # ".xinitrc".source = ./assets/.xinitrc;
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
        activationScript = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          # Create mount dirs
          mkdir -p $HOME/mnt/
          ln -sf /mnt/NAS $HOME/mnt/
          ln -sf -T /run/media/${cfg.username} ~/mnt/usb

          # Symlink picom config file
          ln -sf $HOME/nix-configs/assets/picom.conf $HOME/.config

          # load terminal theme
          # ${pkgs.dconf}/bin/dconf load /com/gexperts/Tilix/ < ${./assets/tilix.dconf}

          # Create ranger's bookmarks
          mkdir -p $HOME/.local/share/ranger/
          sed "s/\$USER/"$USER"/" ${./assets/ranger/bookmarks} > $HOME/.local/share/ranger/bookmarks

          # Datagrip
          ln -sf $HOME/nix-configs/assets/Datagrip/DataGripProjects $HOME

          # Install VideoHelper companion
          ${pkgs.vdhcoapp}/bin/vdhcoapp install
        '';
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
    };
}
