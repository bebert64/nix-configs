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
      cfg = config.by-db;
      homeDir = config.home.homeDirectory;
      stashDir = "${homeDir}/.stash";
      stashBackupDir = "${cfg.paths.nasBase}/Comics/Fini/Planet of the Apes/14 Planet of the Apes issues/Elseworlds/stash_backup";
    in
    {
      by-db-pkgs = {
        backup = {
          service = {
            enable = true;
            runAt = "*-*-* 04:00:00";
          };
          postgresBackupDir = "${cfg.paths.nasBase}/Backup/postgres";
          stashApp = {
            database = {
              apiConfig = cfg.stashApiConfigLocal;
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
              backupDir = "${cfg.paths.nasBase}/Backup/guitar/metadata";
            };
            snapshotDirs = {
              targets = [
                "${homeDir}/.local/share/guitar/data"
                "${homeDir}/.local/share/guitar/plugins"
                "${homeDir}/.local/share/guitar/root"
                "${homeDir}/.config/guitar"
              ];
              backupFileName = "guitar_config";
              backupDir = "${cfg.paths.nasBase}/Backup/guitar";
            };
          };
          media = {
            metadata = {
              targetDir = "${homeDir}/.local/share/media/metadata";
              backupDir = "${cfg.paths.nasBase}/Backup/media/metadata";
            };
            snapshotDirs = {
              targets = [
                "${homeDir}/.local/share/media/data"
                "${homeDir}/.local/share/media/plugins"
                "${homeDir}/.local/share/media/root"
                "${homeDir}/.config/media"
              ];
              backupFileName = "media_config";
              backupDir = "${cfg.paths.nasBase}/Backup/media";
            };
          };
          qbittorrent = {
            configFile = {
              targets = [ "${homeDir}/.config/qBittorrent/qBittorrent.conf" ];
              backupFileName = "qBittorrent.conf";
              backupDir = "${cfg.paths.nasBase}/Backup/qbittorrent";
            };
          };
        };

        guitar-tutorials = {
          service = {
            enable = true;
            runAt = "*-*-* 02:00:00";
          };
          tabsDir = "${cfg.paths.nasBase}/Guitare/Tabs";
          ytDlp = {
            downloadDir = "${cfg.paths.nasBase}/Guitare/YouTube";
            cookiePath = "${homeDir}/.config/by_db/guitar-tutorials-yt-dlp-cookie.txt";
          };
          firefox = {
            guitarTutoFolder = "toolbar/Guitar tutos";
            ffsync = cfg.ffsync.bebert64 // {
              sessionFile = "${homeDir}/.config/by_db/guitar-tutorials-firefox-sync-client.secret";
            };
          };
          guitarService = cfg.guitarService;
        };

        shortcuts = {
          service = {
            enable = true;
            runAt = "*-*-* 00:00:00";
          };
          postgres = cfg.postgres;
          stashApiConfig = cfg.stashApiConfig;
          shortcutsDirs = cfg.shortcutsDirs;
          parallelDownloads = "4";
          firefox = {
            ffsync = cfg.ffsync.shortcutsDb // {
              sessionFile = "${homeDir}/.config/by_db/shortcuts-firefox-sync-client.secret";
            };
            videosToDownloadFolder = "toolbar/DL";
            comixToDownloadFolder = "toolbar/Other";
          };
        };

        wallpapers-manager = {
          services = {
            change = {
              commandArgs = "";
              frequency = "1h";
            };
            download = {
              enable = true;
              bookmarkDir = "toolbar/Wallpaper/Download";
              runAt = "*-*-* 23:00:00";
            };
          };
          wallpapersDir = "${cfg.paths.nasBase}/Wallpapers";
          singleScreenDirName = "SingleScreen";
          dualScreenDirName = "DualScreen";
          animatedDirName = "Animated";
          firefox = {
            ffsync = cfg.ffsync.bebert64 // {
              sessionFile = "${homeDir}/.config/by_db/wallpapers-manager-firefox-sync-client.secret";
            };
            wallpapersFolder = "toolbar/Wallpaper/Download";
          };
        };
      };
    };
}
