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
          (pkgs.writeScriptBin "wol-by-db" ''
            #!/usr/bin/env bash
            TARGETMAC="$1"

            if [ -z "$TARGETMAC" ]; then
              echo "Usage: $0 <MAC_ADDRESS>" >&2
              exit 1
            fi

            (
              printf 'ffffffffffff'
              for i in $(seq 1 16); do
                echo -n \$\{TARGETMAC//:/\}
              done
            ) | xxd -r -p | socat - UDP4-DATAGRAM:192.168.1.255:9,broadcast
          '')
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
