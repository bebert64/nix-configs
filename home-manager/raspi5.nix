{
  by-db,
  config,
  ...
}:
{
  imports = [
    ./raspberry.nix
    ../programs/jellyfin
    ../programs/qbittorrent
    ../programs/stash
    by-db.module.aarch64-linux
  ];

  config =
    let
      homeManagerBydbConfig = config.byDb;
      secrets = homeManagerBydbConfig.secrets;
      paths = homeManagerBydbConfig.paths;
      stashDir = "${paths.home}/.stash";
      stashBackupDir = "${paths.nasBase}/Comics/Fini/Planet of the Apes/14 Planet of the Apes issues/Elseworlds/stash_backup";
    in
    {
      byDbPkgs = {
        backup = {
          service = {
            enable = true;
            runAt = "*-*-* 04:00:00";
          };
          postgresBackupDir = "${paths.nasBase}/Backup/postgres";
          stashApp = {
            database = {
              apiConfig = {
                url = "http://localhost:9999/graphql";
                apiKey = secrets.stashApiKey;
              };
              file = "${stashDir}/stash-go.sqlite";
              otherFilesToRemove = [
                "${stashDir}/stash-go.sqlite-shm"
                "${stashDir}/stash-go.sqlite-wal"
              ];
              downloadDir = "${stashDir}/generated/download_stage";
              backupDir = stashBackupDir;
            };
            thumbnailsDir = {
              targetDir = "${stashDir}/data";
              backupDir = "${stashBackupDir}/thumbnails";
            };
            configFile = {
              targets = [ "${stashDir}/config.yml" ];
              backupFileName = "config.yml";
              backupDir = stashBackupDir;
            };
          };
          guitar = {
            metadata = {
              targetDir = "${paths.homeLocalShare}/guitar/metadata";
              backupDir = "${paths.nasBase}/Backup/guitar/metadata";
            };
            snapshotDirs = {
              targets = [
                "${paths.homeLocalShare}/guitar/data"
                "${paths.homeLocalShare}/guitar/plugins"
                "${paths.homeLocalShare}/guitar/root"
                "${paths.homeConfig}/guitar"
              ];
              backupFileName = "guitar_config";
              backupDir = "${paths.nasBase}/Backup/guitar";
            };
          };
          media = {
            metadata = {
              targetDir = "${paths.homeLocalShare}/media/metadata";
              backupDir = "${paths.nasBase}/Backup/media/metadata";
            };
            snapshotDirs = {
              targets = [
                "${paths.homeLocalShare}/media/data"
                "${paths.homeLocalShare}/media/plugins"
                "${paths.homeLocalShare}/media/root"
                "${paths.homeConfig}/media"
              ];
              backupFileName = "media_config";
              backupDir = "${paths.nasBase}/Backup/media";
            };
          };
          qbittorrent = {
            configFile = {
              targets = [ "${paths.homeConfig}/qBittorrent/qBittorrent.conf" ];
              backupFileName = "qBittorrent.conf";
              backupDir = "${paths.nasBase}/Backup/qbittorrent";
            };
          };
        };

        guitar-tutorials = {
          service = {
            enable = true;
            runAt = "*-*-* 02:00:00";
          };
          tabsDir = "${paths.nasBase}/Guitare/Tabs";
          ytDlp = {
            downloadDir = "${paths.nasBase}/Guitare/YouTube";
            cookiePath = "${paths.homeConfigBydb}/guitar-tutorials-yt-dlp-cookie.txt";
          };
          firefox = {
            guitarTutoFolder = "toolbar/Guitar tutos";
            ffsync = homeManagerBydbConfig.ffsync.bebert64 // {
              sessionFile = "${paths.homeConfigBydb}/guitar-tutorials-firefox-sync-client.secret";
            };
          };
          jellyfin = homeManagerBydbConfig.guitarJellyfinService;
        };

        shortcuts = {
          service = {
            enable = true;
            runAt = "*-*-* 00:00:00";
          };
          postgres = homeManagerBydbConfig.postgres;
          stashApiConfig = homeManagerBydbConfig.stashApiConfig;
          shortcutsDirs = homeManagerBydbConfig.shortcutsDirs;
          parallelDownloads = "4";
          firefox = {
            ffsync = homeManagerBydbConfig.ffsync.shortcutsDb // {
              sessionFile = "${paths.homeConfigBydb}/shortcuts-firefox-sync-client.secret";
            };
            videosToDownloadFolder = "toolbar/DL";
            comixToDownloadFolder = "toolbar/Other";
          };
        };

        wallpapers-manager = {
          services = {
            download = {
              enable = true;
              bookmarkDir = "toolbar/Wallpaper/Download";
              runAt = "*-*-* 23:00:00";
            };
          };
          wallpapersDir = "${paths.nasBase}/Wallpapers";
          singleScreenDirName = "SingleScreen";
          dualScreenDirName = "DualScreen";
          animatedDirName = "Animated";
          firefox = {
            ffsync = homeManagerBydbConfig.ffsync.bebert64 // {
              sessionFile = "${paths.homeConfigBydb}/wallpapers-manager-firefox-sync-client.secret";
            };
            wallpapersFolder = "toolbar/Wallpaper/Download";
          };
        };
      };
    };
}
