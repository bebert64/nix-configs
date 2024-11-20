{ pkgs
, lib
, by-db
, config
, ...
}:
let
  inherit (lib) mkOption types;
  inherit (types) str;
in
{
  imports = [
    ../programs/ranger
    ../programs/secrets
    ../programs/ssh
    ../programs/zsh
    ../programs/btop.nix
    ../programs/direnv.nix
    ../programs/git.nix
    ../programs/vim.nix
    ../scripts.nix
    by-db.module
  ];

  options.by-db = {
    username = mkOption { type = str; };
  };

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
            nixpkgs-fmt
            nodejs
            nodePackages.npm
            nodePackages.pnpm
            polkit_gnome
            rsync
            sshfs
            unrar
            unzip
            yt-dlp
            zip
          ]
        );

        file = {
          # ".cargo/config.toml".source = ./assets/cargo_config.toml;
        };
      };

      programs = {
        # Let Home Manager install and manage itself.
        home-manager.enable = true;
      };

      by-db-pkgs = { };

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
