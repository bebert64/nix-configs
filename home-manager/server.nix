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
                echo -n ''${TARGETMAC//:/}
              done
            ) | xxd -r -p | socat - UDP4-DATAGRAM:192.168.1.255:9,broadcast
          '')
        ]
        # Add common packages using home-manager's pkgs (or system's pkgs if useGlobalPkgs=true)
        # For raspi5, these will come from nixos-raspberrypi's nixpkgs to avoid collisions
        ++ (with pkgs; [
          p7zip
          nixd
          nixfmt-rfc-style
          nodePackages.npm
          nodePackages.pnpm
          polkit_gnome
          rsync
          screen
          sshfs
          unrar
          yt-dlp
        ]);
      };

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
