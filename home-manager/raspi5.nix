{
  by-db,
  config,
  ...
}:
{
  imports = [
    ./raspberry.nix
    ../programs/jellyfin
    ../programs/postgresql
    ../programs/qbittorrent
    ../programs/stash
    by-db.module.aarch64-linux
  ];

  config =
    let
      cfg = config.by-db;
    in
    {
      by-db-pkgs = {
        backup = {
          service.enable = true;

          stashApp.database.apiConfig.apiKey = "${config.sops.secrets."stash/api-key".path}";
        };

        guitar-tutorials = {
          service.enable = true;

          firefox.ffsync = cfg.ffsync.bebert64;
          guitarService = {
            accessToken = "${config.sops.secrets."jellyfin/guitar/access-token".path}";
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
