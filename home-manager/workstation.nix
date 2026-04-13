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
    ../programs/autossh-orthos
    ../programs/avidemux
    ../programs/battery-notifier
    ../programs/calculator
    ../programs/chromium
    ../programs/claude-code/workstation.nix
    ../programs/eww
    ../programs/cursor
    ../programs/datagrip
    ../programs/ferdium
    ../programs/firefox
    ../programs/screenshots
    ../programs/insomnia
    ../programs/kanshi
    ../programs/kitty
    ../programs/lock
    ../programs/mako
    ../programs/music
    ../programs/notion-todo-sync
    ../programs/plex-desktop
    ../programs/ranger/workstation.nix
    ../programs/rofi
    ../programs/slack
    ../programs/sqlfluff
    ../programs/sway
    ../programs/theme
    ../programs/udiskie
    ../programs/vdhcoapp
    ../programs/waybar
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
    isHeadphonesOnCommand = lib.mkOption {
      type = lib.types.str;
      description = "Command that returns whether headphones are the current output";
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
      inherit (homeManagerBydbConfig) paths;
      homeDir = config.home.homeDirectory;
    in
    {
      home = {
        packages =
          (with pkgs; [
            anydesk
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
            wdisplays # GUI to configure screens positions (Wayland, replaces arandr)
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
        db-cli = {
          enable = true;
        };
        video-manager = {
          enable = true;
          stash = homeManagerBydbConfig.stashApiConfig;
        };
        guitar-tutorials = {
          app.enable = true;
          tabsDir = "${paths.nasBase}/Guitare/Tabs";
          ytDlp = {
            downloadDir = "${paths.nasBase}/Guitare/YouTube";
            cookiePath = "${homeDir}/.config/by_db/guitar-tutorials-yt-dlp-cookie.txt";
          };
          firefox = {
            guitarTutoFolder = "toolbar/Downloads/Guitar tutos";
            ffsync = homeManagerBydbConfig.ffsync.bebert64 // {
              sessionFile = "${homeDir}/.config/by_db/guitar-tutorials-firefox-sync-client.secret";
            };
          };
          jellyfin = homeManagerBydbConfig.guitarJellyfinService;
        };
        shortcuts = {
          app.enable = true;
          inherit (homeManagerBydbConfig) postgres;
          inherit (homeManagerBydbConfig) stashApiConfig;
          inherit (homeManagerBydbConfig) shortcutsDirs;
          parallelDownloads = "4";
          firefox = {
            ffsync = homeManagerBydbConfig.ffsync.shortcutsDb // {
              sessionFile = "${homeDir}/.config/by_db/shortcuts-firefox-sync-client.secret";
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
          wallpapersDir = "${homeDir}/wallpapers";
          singleScreenDirName = "SingleScreen";
          dualScreenDirName = "DualScreen";
          firefox = {
            ffsync = homeManagerBydbConfig.ffsync.bebert64 // {
              sessionFile = "${homeDir}/.config/by_db/wallpapers-manager-firefox-sync-client.secret";
            };
            wallpapersFolder = "toolbar/Downloads/Wallpaper/Download";
          };
        };
      };

      xdg = {
        enable = true;
        userDirs = {
          enable = true;
          createDirectories = false;
          desktop = "${homeDir}";
          download = "${homeDir}/downloads";
          documents = "${homeDir}";
          music = "${homeDir}";
          pictures = "${homeDir}";
          publicShare = "${homeDir}";
          templates = "${homeDir}";
          videos = "${homeDir}";
        };
        mimeApps = {
          enable = true;
          associations.added = {
            "text/html" = [ "chromium-browser.desktop" ];
            "text/xml" = [ "chromium-browser.desktop" ];
            "x-scheme-handler/http" = [ "chromium-browser.desktop" ];
            "x-scheme-handler/https" = [ "chromium-browser.desktop" ];
          };
          defaultApplications = {
            "text/html" = [ "chromium-browser.desktop" ];
            "text/xml" = [ "chromium-browser.desktop" ];
            "x-scheme-handler/http" = [ "chromium-browser.desktop" ];
            "x-scheme-handler/https" = [ "chromium-browser.desktop" ];
          };
        };
      };
    };
}
