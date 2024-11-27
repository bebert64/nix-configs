{ pkgs
, lib
, config
, by-db
, ...
}:
let
  inherit (lib) mkEnableOption mkOption types;
  inherit (types) str;
in
{
  imports = [
    ./common.nix
    ../programs/workstation.nix
    by-db.homeManagerModule.x86_64-linux
    ../fonts
  ];

  options.by-db = {
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

        packages =
          (with pkgs; [
            arandr # GUI to configure screens positions (need to kill autorandr)
            chromium
            evince # pdf reader
            fusee-launcher
            gnome.gnome-keyring
            inkscape
            microcodeIntel # for increased microprocessor performance
            mcomix
            pavucontrol # pulse audio volume controle
            vlc
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
        caffeine.enable = true;
      };

      by-db-pkgs = {
        wallpapers-manager = {
          services = {
            change = {
              enable = true;
              commandArgs = "--mode fifty-fifty";
            };
          };
          ffsync = {
            username = "bebert64@gmail.com";
            passwordPath = "${config.sops.secrets."ffsync/bebert64".path}";
          };
        };
        shortcuts = {
          app.enable = true;
          postgres.password = "${config.sops.secrets."raspi/postgresql/rw".path}";
          ffsync = {
            username = "shortcuts.db@gmail.com";
            passwordPath = "${config.sops.secrets."ffsync/shortcuts-db".path}";
          };
          apiKey = "${config.sops.secrets."stash/api-key".path}";
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
    };
}
