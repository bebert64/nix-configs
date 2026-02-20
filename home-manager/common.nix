{
  pkgs,
  lib,
  config,
  ...
}:
let
  homeManagerBydbConfig = config.byDb;
  homeDir = config.home.homeDirectory;
in
{
  options.byDb = {
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
    codeRoot = lib.mkOption {
      type = lib.types.str;
      default = "code";
      description = "Name of the root code directory containing worktrees and repos";
    };
    nixConfigsRelativePath = lib.mkOption {
      type = lib.types.str;
      default = "${config.byDb.codeRoot}/nix-configs";
      description = "Relative path from home to the nix configs repo";
    };
    paths = {
      nasBase = lib.mkOption {
        type = lib.types.str;
        description = "Base path for NAS mount point — set by nas.nix";
      };
      codeRoot = lib.mkOption {
        type = lib.types.str;
        internal = true;
        readOnly = true;
        default = "${homeDir}/${config.byDb.codeRoot}";
        description = "Full path to the root code directory";
      };
      mainWorktree = lib.mkOption {
        type = lib.types.str;
        internal = true;
        readOnly = true;
        default = "${homeDir}/${config.byDb.codeRoot}/Main";
        description = "Full path to the main worktree of the coding repo";
      };
      nixConfigs = lib.mkOption {
        type = lib.types.str;
        internal = true;
        readOnly = true;
        default = "${homeDir}/${config.byDb.nixConfigsRelativePath}";
        description = "Full path to the nix configs repo";
      };
      nixPrograms = lib.mkOption {
        type = lib.types.str;
        internal = true;
        readOnly = true;
        default = "${config.byDb.paths.nixConfigs}/programs";
        description = "Full path to the programs directory in the nix configs repo";
      };
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
    guitarJellyfinService = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = "Guitar tutorials Jellyfin service config — shared by guitar-tutorials crate";
      default = {
        url = "https://guitar.capucina.net";
        userId = "b4817b818e794ffd9ae445048320ed44";
        accessToken = homeManagerBydbConfig.secrets.jellyfinGuitarAccessToken;
      };
    };
    shortcutsDirs = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = "Shortcuts directory structure — shared by shortcuts crate";
      default = {
        root = "${homeManagerBydbConfig.paths.nasBase}/Comics/Fini/Planet of the Apes/14 Planet of the Apes issues/Elseworlds/";
        toCut = "Videos a couper";
        cut = "Videos cut";
        cutTmp = "Temp cut";
        playlists = "Playlists";
        comix = "BD";
      };
    };
    stashApiConfig = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = "Stash API config (remote) — used by video-manager, shortcuts";
      default = {
        url = "https://stash.capucina.net/graphql";
        apiKey = homeManagerBydbConfig.secrets.stashApiKey;
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
    ../programs/zsh/home-manager.nix
  ];

  config = {
    home = {
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
