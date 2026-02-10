{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkOption types;
  inherit (types) str;
in
{
  options.by-db = {
    username = mkOption { type = str; };
    ffsync = {
      bebert64 = {
        username = mkOption {
          type = str;
          default = "bebert64@gmail.com";
        };
        passwordPath = mkOption {
          type = str;
          default = "${config.sops.secrets."ffsync/bebert64".path}";
        };
      };
      shortcutsDb = {
        username = mkOption {
          type = str;
          default = "shortcuts.db@gmail.com";
        };
        passwordPath = mkOption {
          type = str;
          default = "${config.sops.secrets."ffsync/shortcuts-db".path}";
        };
      };
    };
    postgres = {
      ip = mkOption {
        type = str;
        default = "capucina.net";
      };
      passwordPath = mkOption {
        type = str;
        default = "${config.sops.secrets."raspi/postgresql/rw".path}";
      };
    };
  };

  imports = [
    ../programs/btop
    ../programs/direnv
    ../programs/git
    ../programs/neovim
    ../programs/ranger
    ../programs/secrets
    ../programs/ssh
    ../programs/zsh
  ];

  config =
    let
      cfg = config.by-db;
    in
    {
      home = {
        username = "${cfg.username}";
        homeDirectory = "/home/${cfg.username}";

        packages = (
          with pkgs;
          [
            nixd
            nixfmt-rfc-style
            p7zip
            rsync
            screen
            wget
            yt-dlp
          ]
        );
      };

      programs = {
        # Let Home Manager install and manage itself.
        home-manager.enable = true;
      };

      nixpkgs.config.allowUnfree = true; # Necessary for unrar

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
