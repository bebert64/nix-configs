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
in
{
  imports = [
    ./programs
    ./scripts.nix
    ./fonts.nix
    by-db.module
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
      home = {
        username = "${cfg.username}";
        homeDirectory = "/home/${cfg.username}";

        packages =
          (with pkgs; [
            arandr # GUI to configure screens positions (need to kill autorandr)
            caffeine-ng # to prevent going to sleep when watching videos
            chromium
            evince # pdf reader
            fusee-launcher
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
          );

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

      by-db-pkgs = {
        strawberry-radios = {
          activationScript.enable = true;
          radios = [
            {
              name = "FIP";
              url = "http://direct.fipradio.fr/live/fip-midfi.mp3";
            }
            {
              name = "FIP Jazz";
              url = "http://direct.fipradio.fr/live/fipjazz-midfi.mp3";
            }
            {
              name = "FIP Rock";
              url = "http://direct.fipradio.fr/live/fiprock-midfi.mp3";
            }
            {
              name = "FIP Groove";
              url = "http://direct.fipradio.fr/live/fipgroove-midfi.mp3";
            }
            {
              name = "FIP Reggae";
              url = "http://direct.fipradio.fr/live/fipreggae-midfi.mp3";
            }
            {
              name = "FIP Pop";
              url = "   http://direct.fipradio.fr/live/fippop-midfi.mp3";
            }
            {
              name = "FIP Monde";
              url = "http://direct.fipradio.fr/live/fipworld-midfi.mp3";
            }
            {
              name = "FIP Nouveautés";
              url = "http://direct.fipradio.fr/live/fipnouveautes-midfi.mp3";
            }
            {
              name = "Radio Nova";
              url = "http://broadcast.infomaniak.ch/radionova-high.mp3";
            }
            {
              name = "Radio Swiss Classic";
              url = "http://stream.srg-ssr.ch/m/rsc_fr/mp3_128";
            }
            {
              name = "Chillhop Music";
              url = "https://streams.fluxfm.de/Chillhop/mp3-128/streams.fluxfm.de/";
            }
          ];
        };
        wallpapers-manager = {
          app.enable = true;
          service = {
            enable = true;
            commandArgs = "--mode fifty-fifty";
          };
          ffsync = {
            username = "bebert64";
            passwordPath = "${config.sops.secrets."ffsync/bebert64".path}";
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
