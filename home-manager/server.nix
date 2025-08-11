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
      home.packages = [
        (pkgs.writeScriptBin "finish-setup" ''
          set -euxo pipefail

          sudo mount-nas
          cp /mnt/NAS/Backup/raspi/id_ed25519 $HOME/.ssh
          cp /mnt/NAS/Backup/raspi/id_ed25519.pub $HOME/.ssh
          cd $HOME
          git clone git@github.com:bebert64/nix-configs

          restore-all
          sudo reboot now
        '')

        (pkgs.writeScriptBin "restore-all" ''
          set -euxo pipefail

          restore-stash
          restore-postgres
        '')
      ];

      by-db-pkgs = {
        wallpapers-manager = {
          wallpapersDir = "/mnt/NAS/Wallpapers";
          services.download = {
            enable = true;
          };
          firefox.ffsync = cfg.ffsync.bebert64;
        };
        shortcuts = {
          service.enable = true;
          postgres = cfg.postgres;
          firefox.ffsync = cfg.ffsync.shortcutsDb;
          stashApiConfig.apiKey = "${config.sops.secrets."stash/api-key".path}";
        };
        guitar-tutorials = {
          service.enable = true;
          firefox.ffsync = cfg.ffsync.bebert64;
          jellyfin = {
            accessToken = "${config.sops.secrets."jellyfin/access-token".path}";
          };
        };
      };
    };
}
