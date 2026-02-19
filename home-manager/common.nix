{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.by-db = {
    bluetooth.enable = lib.mkOption {
      type = lib.types.bool;
      description = "Enable bluetooth (synced from NixOS by-db.bluetooth.enable)";
    };
    user = {
      name = lib.mkOption { type = lib.types.str; };
      description = lib.mkOption { type = lib.types.str; };
    };
    ffsync = {
      bebert64 = {
        username = lib.mkOption {
          type = lib.types.str;
          default = "bebert64@gmail.com";
        };
        passwordPath = lib.mkOption {
          type = lib.types.str;
          default = "${config.sops.secrets."ffsync/bebert64".path}";
        };
      };
      shortcutsDb = {
        username = lib.mkOption {
          type = lib.types.str;
          default = "shortcuts.db@gmail.com";
        };
        passwordPath = lib.mkOption {
          type = lib.types.str;
          default = "${config.sops.secrets."ffsync/shortcuts-db".path}";
        };
      };
    };
    postgres = {
      ip = lib.mkOption {
        type = lib.types.str;
        default = "capucina.net";
      };
      passwordPath = lib.mkOption {
        type = lib.types.str;
        default = "${config.sops.secrets."raspi/postgresql/rw".path}";
      };
      username = lib.mkOption {
        type = lib.types.str;
        default = "rw";
      };
      port = lib.mkOption {
        type = lib.types.str;
        default = "5432";
      };
      nameProd = lib.mkOption {
        type = lib.types.str;
        default = "shortcuts_prod";
      };
      nameDev = lib.mkOption {
        type = lib.types.str;
        default = "shortcuts_dev";
      };
    };
    paths = {
      nasBase = lib.mkOption {
        type = lib.types.str;
        default = "/mnt/NAS";
      };
    };
    nixConfigsRepo = lib.mkOption {
      type = lib.types.str;
      default = "nix-configs";
      description = "Name of the nix configs repo directory (e.g. nix-configs or nix-config)";
    };
    nixConfigsPath = lib.mkOption {
      type = lib.types.str;
      internal = true;
      readOnly = true;
      default = "${config.home.homeDirectory}/${config.by-db.nixConfigsRepo}";
      description = "Full path to the nix configs repo";
    };
    secrets = {
      stashApiKey = lib.mkOption {
        type = lib.types.str;
        default = "${config.sops.secrets."stash/api-key".path}";
      };
      jellyfinGuitarAccessToken = lib.mkOption {
        type = lib.types.str;
        default = "${config.sops.secrets."jellyfin/guitar/access-token".path}";
      };
      radioFranceApiKey = lib.mkOption {
        type = lib.types.str;
        default = "${config.sops.secrets."radio-france/api-key".path}";
      };
    };
    # Factorized defaults for by-db-pkgs (avoid repeating same values)
    stashApiConfig = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = "Stash API config (remote) — used by video-manager, shortcuts";
    };
    stashApiConfigLocal = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = "Stash API config (local) — used by backup when stash runs on same host";
    };
    shortcutsDirs = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = "Shortcuts directory structure — shared by shortcuts crate";
    };
    guitarService = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = "Guitar tutorials Jellyfin service config — shared by guitar-tutorials crate";
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
      byDbHomeManager = config.by-db;
    in
    {
      by-db = {
        stashApiConfig = {
          url = "https://stash.capucina.net/graphql";
          apiKey = byDbHomeManager.secrets.stashApiKey;
        };
        stashApiConfigLocal = {
          url = "http://localhost:9999/graphql";
          apiKey = byDbHomeManager.secrets.stashApiKey;
        };
        shortcutsDirs = {
          root = "${byDbHomeManager.paths.nasBase}/Comics/Fini/Planet of the Apes/14 Planet of the Apes issues/Elseworlds/";
          toCut = "Videos a couper";
          cut = "Videos cut";
          cutTmp = "Temp cut";
          playlists = "Playlists";
          comix = "BD";
        };
        guitarService = {
          url = "https://guitar.capucina.net";
          userId = "b4817b818e794ffd9ae445048320ed44";
          accessToken = byDbHomeManager.secrets.jellyfinGuitarAccessToken;
        };
      };

      home = {
        username = "${byDbHomeManager.user.name}";
        homeDirectory = "/home/${byDbHomeManager.user.name}";

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
