{
  pkgs,
  lib,
  config,
  nixneovimplugins,
  ...
}:
let
  inherit (lib) mkOption types;
  inherit (types) str;
in
{
  options.by-db = {
    username = mkOption { type = str; };
  };

  config =
    let
      cfg = config.by-db;
    in
    {
      nixpkgs.overlays = [
        nixneovimplugins.overlays.default
      ];

      home = {
        username = "${cfg.username}";
        homeDirectory = "/home/${cfg.username}";

        packages = (
          with pkgs;
          [
            nixd
            nixfmt-rfc-style
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
