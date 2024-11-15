{
  pkgs,
  lib,
  by-db,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkOption types;
  inherit (types) str;
  inherit (by-db.packages.x86_64-linux) wallpapers-manager;
in
{
  imports = [
    ./programs/common-user.nix
    ./scripts.nix
    ./fonts.nix
  ];

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
    setHeadphonesCommand = mkOption {
      type = str;
      description = "Command to redirect the sound output to headphones";
    };
    setSpeakerCommand = mkOption {
      type = str;
      description = "Command to redirect the sound output to speaker";
    };
  };

  config =
    let
      cfg = config.by-db;
    in
    {
      nixpkgs.config.allowUnfree = true; # Necessary for vscode

      home = {
        username = "${cfg.username}";
        homeDirectory = "/home/${cfg.username}";

        packages =
          (with pkgs; [
            arandr # GUI to configure screens positions (need to kill autorandr)
            avidemux
            caffeine-ng # to prevent going to sleep when watching videos
            chromium
            evince # pdf reader
            feh
            fusee-launcher
            gnome.gnome-calculator
            gnome.gnome-keyring
            inkscape
            microcodeIntel # for increased microprocessor performance
            mcomix
            nixd
            nixfmt-rfc-style
            nixpkgs-fmt
            nodejs
            nodePackages.npm
            nodePackages.pnpm
            pavucontrol # pulse audio volume controle
            polkit_gnome
            rsync
            slack
            sshfs
            unrar
            unzip
            vlc
            yt-dlp
            zip
          ])
          ++ lib.optionals cfg.wifi.enable (
            with pkgs;
            [
              networkmanager
              networkmanagerapplet
            ]
          )
          ++ [ wallpapers-manager ];

        file = {
          ".themes".source = "${pkgs.palenight-theme}/share/themes";
          # ".cargo/config.toml".source = ./assets/cargo_config.toml;
        };

        pointerCursor = {
          x11.enable = true;
          package = pkgs.gnome.adwaita-icon-theme;
          name = "Adwaita";
          size = 32;
        };
      };

      programs = {
        # Let Home Manager install and manage itself.
        home-manager.enable = true;
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

      gtk = {
        enable = true;
        theme = {
          name = "palenight";
          package = pkgs.palenight-theme;
        };
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
