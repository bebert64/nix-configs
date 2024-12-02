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
    ./fonts
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
            anydesk
            arandr # GUI to configure screens positions (need to kill autorandr)
            chromium
            evince # pdf reader
            fusee-launcher
            gnome-keyring
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
