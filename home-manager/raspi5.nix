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
      byDbHomeManager = config.byDb;
      homeDir = config.home.homeDirectory;
      stashDir = "${homeDir}/.stash";
      stashBackupDir = "${byDbHomeManager.paths.nasBase}/Comics/Fini/Planet of the Apes/14 Planet of the Apes issues/Elseworlds/stash_backup";
    in
    {
      byDbPkgs = {
        backup = {
          service = {
            enable = true;
            runAt = "*-*-* 04:00:00";
          };
          postgresBackupDir = "${byDbHomeManager.paths.nasBase}/Backup/postgres";
          stashApp = {
            database = {
              apiConfig = {
                url = "http://localhost:9999/graphql";
                apiKey = byDbHomeManager.secrets.stashApiKey;
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
              targetDir = "${homeDir}/.local/share/guitar/metadata";
              backupDir = "${byDbHomeManager.paths.nasBase}/Backup/guitar/metadata";
            };
            snapshotDirs = {
              targets = [
                "${homeDir}/.local/share/guitar/data"
                "${homeDir}/.local/share/guitar/plugins"
                "${homeDir}/.local/share/guitar/root"
                "${homeDir}/.config/guitar"
              ];
              backupFileName = "guitar_config";
              backupDir = "${byDbHomeManager.paths.nasBase}/Backup/guitar";
            };
          };
          media = {
            metadata = {
              targetDir = "${homeDir}/.local/share/media/metadata";
              backupDir = "${byDbHomeManager.paths.nasBase}/Backup/media/metadata";
            };
            snapshotDirs = {
              targets = [
                "${homeDir}/.local/share/media/data"
                "${homeDir}/.local/share/media/plugins"
                "${homeDir}/.local/share/media/root"
                "${homeDir}/.config/media"
              ];
              backupFileName = "media_config";
              backupDir = "${byDbHomeManager.paths.nasBase}/Backup/media";
            };
          };
          qbittorrent = {
            configFile = {
              targets = [ "${homeDir}/.config/qBittorrent/qBittorrent.conf" ];
              backupFileName = "qBittorrent.conf";
              backupDir = "${byDbHomeManager.paths.nasBase}/Backup/qbittorrent";
            };
          };
        };

        guitar-tutorials = {
          service = {
            enable = true;
            runAt = "*-*-* 02:00:00";
          };
          tabsDir = "${byDbHomeManager.paths.nasBase}/Guitare/Tabs";
          ytDlp = {
            downloadDir = "${byDbHomeManager.paths.nasBase}/Guitare/YouTube";
            cookiePath = "${homeDir}/.config/by_db/guitar-tutorials-yt-dlp-cookie.txt";
          };
          firefox = {
            guitarTutoFolder = "toolbar/Guitar tutos";
            ffsync = byDbHomeManager.ffsync.bebert64 // {
              sessionFile = "${homeDir}/.config/by_db/guitar-tutorials-firefox-sync-client.secret";
            };
          };
          jellyfin = byDbHomeManager.guitarJellyfinService;
        };

        shortcuts = {
          service = {
            enable = true;
            runAt = "*-*-* 00:00:00";
          };
          postgres = byDbHomeManager.postgres;
          stashApiConfig = byDbHomeManager.stashApiConfig;
          shortcutsDirs = byDbHomeManager.shortcutsDirs;
          parallelDownloads = "4";
          firefox = {
            ffsync = byDbHomeManager.ffsync.shortcutsDb // {
              sessionFile = "${homeDir}/.config/by_db/shortcuts-firefox-sync-client.secret";
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
          wallpapersDir = "${byDbHomeManager.paths.nasBase}/Wallpapers";
          singleScreenDirName = "SingleScreen";
          dualScreenDirName = "DualScreen";
          animatedDirName = "Animated";
          firefox = {
            ffsync = byDbHomeManager.ffsync.bebert64 // {
              sessionFile = "${homeDir}/.config/by_db/wallpapers-manager-firefox-sync-client.secret";
            };
            wallpapersFolder = "toolbar/Wallpaper/Download";
          };
        };
      };
    };
}
