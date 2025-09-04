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
    ../programs/server-user.nix
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
          app.enable = true;
          stashApp.database.stashApiConfig.apiKey = "${config.sops.secrets."stash/api-key".path}";
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
          postgres = cfg.postgres;
          firefox.ffsync = cfg.ffsync.shortcutsDb;
          stashApiConfig.apiKey = "${config.sops.secrets."stash/api-key".path}";
        };

        wallpapers-manager = {
          wallpapersDir = "/mnt/NAS/Wallpapers";
          services.download = {
            enable = true;
          };
          firefox.ffsync = cfg.ffsync.bebert64;
        };
      };
    };
}
