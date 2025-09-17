{
  pkgs,
  lib,
  config,
  by-db,
  ...
}:
let
  inherit (lib) mkEnableOption mkOption types;
  inherit (types) str;
in
{
  imports = [
    ./common.nix
    ../programs/workstation.nix
    by-db.module.x86_64-linux
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
        default = "";
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
            anydesk
            arandr # GUI to configure screens positions (need to kill autorandr)
            chromium
            evince # pdf reader
            filezilla
            fusee-launcher
            gnome-keyring
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
        compress-videos = {
          enable = true;
          jellyfin.accessToken = "${config.sops.secrets."jellyfin/access-token".path}";
          stash.apiKey = "${config.sops.secrets."stash/api-key".path}";
        };
        guitar-tutorials = {
          app.enable = true;
          firefox.ffsync = cfg.ffsync.bebert64;
          jellyfin.accessToken = "${config.sops.secrets."jellyfin/access-token".path}";
        };
        shortcuts = {
          app.enable = true;
          postgres = cfg.postgres;
          firefox.ffsync = cfg.ffsync.shortcutsDb;
          stashApiConfig.apiKey = "${config.sops.secrets."stash/api-key".path}";
        };
        wallpapers-manager = {
          services = {
            change = {
              enable = true;
              commandArgs = "--mode fifty-fifty";
            };
          };
          firefox.ffsync = cfg.ffsync.bebert64;
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
