{
  pkgs,
  by-db,
  config,
  ...
}:
{
  imports = [
    ./common.nix
    by-db.module.aarch64-linux
  ];

  config =
    let
      cfg = config.by-db;
    in
    {
      home = {
        packages = [
          pkgs.wol
        ];
      };

      by-db-pkgs = {
        backup = {
          service.enable = true;

          stashApp.database.apiConfig.apiKey = "${config.sops.secrets."stash/api-key".path}";
        };

        guitar-tutorials = {
          service.enable = true;

          firefox.ffsync = cfg.ffsync.bebert64;
          jellyfin = {
            accessToken = "${config.sops.secrets."jellyfin/access-token".path}";
          };
        };

        shortcuts = {
          service.enable = true;

          firefox.ffsync = cfg.ffsync.shortcutsDb;
          postgres = cfg.postgres;
          stashApiConfig.apiKey = "${config.sops.secrets."stash/api-key".path}";
        };

        wallpapers-manager = {
          services.download = {
            enable = true;
          };

          firefox.ffsync = cfg.ffsync.bebert64;
          wallpapersDir = "/mnt/NAS/Wallpapers";
        };
      };
    };
}
