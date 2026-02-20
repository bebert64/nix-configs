{
  by-db,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./common.nix
    ../programs/chromium
    ../programs/autorandr
    ../programs/avidemux
    ../programs/calculator
    ../programs/conky
    ../programs/cursor
    ../programs/datagrip
    ../programs/ferdium
    ../programs/firefox
    ../programs/flameshot
    ../programs/i3
    ../programs/insomnia
    ../programs/lock
    ../programs/music
    ../programs/picom
    ../programs/plex-desktop
    ../programs/polybar
    ../programs/rofi
    ../programs/slack
    ../programs/sqlfluff
    ../programs/terminal
    ../programs/theme
    ../programs/udiskie
    ../programs/vdhcoapp
    by-db.module.x86_64-linux
  ];

  options.byDb = {
    screens = {
      primary = lib.mkOption {
        type = lib.types.str;
        description = "The primary screen";
      };
      secondary = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "The secondary screen";
      };
    };
    setHeadphonesCommand = lib.mkOption {
      type = lib.types.str;
      description = "Command to redirect the sound output to headphones";
    };
    setSpeakerCommand = lib.mkOption {
      type = lib.types.str;
      description = "Command to redirect the sound output to speaker";
    };
    wifi.enable = lib.mkEnableOption "Whether or not to install network manager";
  };

  config =
    let
      homeManagerBydbConfig = config.byDb;
      paths = homeManagerBydbConfig.paths;
    in
    {
      home = {
        packages =
          (with pkgs; [
            anydesk
            arandr # GUI to configure screens positions (need to kill autorandr)
            evince # pdf reader
            filezilla
            fusee-interfacee-tk
            gnome-keyring
            inkscape
            microcode-intel # for increased microprocessor performance
            mcomix
            nodePackages.npm
            nodePackages.pnpm
            ntfs3g
            pavucontrol # pulse audio volume controle
            polkit_gnome
            vlc
          ])
          ++ lib.optionals homeManagerBydbConfig.wifi.enable (
            with pkgs;
            [
              networkmanager
              networkmanagerapplet
            ]
          );
      };

      programs = {
        home-manager.enable = true;
      };

      services = {
        playerctld.enable = true;
        caffeine.enable = true;
      };

      byDbPkgs = {
        video-manager = {
          enable = true;
          stash = homeManagerBydbConfig.stashApiConfig;
        };
        guitar-tutorials = {
          app.enable = true;
          tabsDir = "${paths.nasBase}/Guitare/Tabs";
          ytDlp = {
            downloadDir = "${paths.nasBase}/Guitare/YouTube";
            cookiePath = "${paths.homeConfigBydb}/guitar-tutorials-yt-dlp-cookie.txt";
          };
          firefox = {
            guitarTutoFolder = "toolbar/Guitar tutos";
            ffsync = homeManagerBydbConfig.ffsync.bebert64 // {
              sessionFile = "${paths.homeConfigBydb}/guitar-tutorials-firefox-sync-client.secret";
            };
          };
          jellyfin = homeManagerBydbConfig.guitarJellyfinService;
        };
        shortcuts = {
          app.enable = true;
          postgres = homeManagerBydbConfig.postgres;
          stashApiConfig = homeManagerBydbConfig.stashApiConfig;
          shortcutsDirs = homeManagerBydbConfig.shortcutsDirs;
          parallelDownloads = "4";
          firefox = {
            ffsync = homeManagerBydbConfig.ffsync.shortcutsDb // {
              sessionFile = "${paths.homeConfigBydb}/shortcuts-firefox-sync-client.secret";
            };
            videosToDownloadFolder = "toolbar/DL";
            comixToDownloadFolder = "toolbar/Other";
          };
        };
        wallpapers-manager = {
          services = {
            change = {
              enable = true;
              commandArgs = "--distribution fifty-fifty";
              frequency = "1h";
            };
          };
          wallpapersDir = "${paths.home}/wallpapers";
          singleScreenDirName = "SingleScreen";
          dualScreenDirName = "DualScreen";
          animatedDirName = "Animated";
          firefox = {
            ffsync = homeManagerBydbConfig.ffsync.bebert64 // {
              sessionFile = "${paths.homeConfigBydb}/wallpapers-manager-firefox-sync-client.secret";
            };
            wallpapersFolder = "toolbar/Wallpaper/Download";
          };
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
            "defaut-web-browser" = [ "chromium-browser.desktop" ];
            "text/html" = [ "chromium-browser.desktop" ];
            "text/xml" = [ "chromium-browser.desktop" ];
            "x-scheme-handler/http" = [ "chromium-browser.desktop" ];
            "x-scheme-handler/https" = [ "chromium-browser.desktop" ];
          };
        };
      };
    };
}
