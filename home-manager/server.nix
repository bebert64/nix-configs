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

        # TODO
        # restore-all
        # ask for reboot
      '')
    ];
    by-db-pkgs = { };
  };
}
