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
      homeDirectory = config.home.homeDirectory;
      secrets = homeManagerBydbConfig.secrets;
      paths = homeManagerBydbConfig.paths;
      stashDir = "${homeDirectory}/.stash";
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
              targetDir = "${homeDirectory}/.local/share/guitar/metadata";
              backupDir = "${paths.nasBase}/Backup/guitar/metadata";
            };
            snapshotDirs = {
              targets = [
                "${homeDirectory}/.local/share/guitar/data"
                "${homeDirectory}/.local/share/guitar/plugins"
                "${homeDirectory}/.local/share/guitar/root"
                "${homeDirectory}/.config/guitar"
              ];
              backupFileName = "guitar_config";
              backupDir = "${paths.nasBase}/Backup/guitar";
            };
          };
          media = {
            metadata = {
              targetDir = "${homeDirectory}/.local/share/media/metadata";
              backupDir = "${paths.nasBase}/Backup/media/metadata";
            };
            snapshotDirs = {
              targets = [
                "${homeDirectory}/.local/share/media/data"
                "${homeDirectory}/.local/share/media/plugins"
                "${homeDirectory}/.local/share/media/root"
                "${homeDirectory}/.config/media"
              ];
              backupFileName = "media_config";
              backupDir = "${paths.nasBase}/Backup/media";
            };
          };
          qbittorrent = {
            configFile = {
              targets = [ "${homeDirectory}/.config/qBittorrent/qBittorrent.conf" ];
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
            cookiePath = "${homeDirectory}/.config/by_db/guitar-tutorials-yt-dlp-cookie.txt";
          };
          firefox = {
            guitarTutoFolder = "toolbar/Guitar tutos";
            ffsync = homeManagerBydbConfig.ffsync.bebert64 // {
              sessionFile = "${homeDirectory}/.config/by_db/guitar-tutorials-firefox-sync-client.secret";
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
              sessionFile = "${homeDirectory}/.config/by_db/shortcuts-firefox-sync-client.secret";
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
              sessionFile = "${homeDirectory}/.config/by_db/wallpapers-manager-firefox-sync-client.secret";
            };
            wallpapersFolder = "toolbar/Wallpaper/Download";
          };
        };
      };
    };
}
