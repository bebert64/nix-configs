{ pkgs, ... }:
{
  imports = [
    ./common.nix
    ../programs/server.nix
  ];

  config = {
    home.packages = [
      (pkgs.writeScriptBin "finish-setup" ''
        set -euxo pipefail

        sudo mount-nas
        sudo cp /mnt/NAS/Backup/raspi/ffmpeg /stash
        sudo cp /mnt/NAS/Backup/raspi/ffprobe /stash
        sudo cp /mnt/NAS/Backup/raspi/stash /stash
        sudo chmod +x /stash/stash
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

      (pkgs.writeScriptBin "restore-stash" ''
        set -euxo pipefail

        sudo rsync -aP '/mnt/NAS/Comics/Fini/Planet of the Apes/14 Planet of the Apes issues/Elseworlds/stash_bkp/' /stash
      '')

      (pkgs.writeScriptBin "restore-postgres" ''
        set -euxo pipefail

        psql -U postgres -w -f /mnt/NAS/Backup/raspi/full_dump_20241029.sql.sql
      '')
    ];
    by-db-pkgs = { };
  };
}
