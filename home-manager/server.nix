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

        mnas
        sudo cp /mnt/NAS/Backup/raspi/ffmpeg /stash
        sudo cp /mnt/NAS/Backup/raspi/ffprobe /stash
        sudo cp /mnt/NAS/Backup/raspi/stash /stash
        cp /mnt/NAS/Backup/raspi/id_ed25519 $HOME/.ssh
        cp /mnt/NAS/Backup/raspi/id_ed25519.pub $HOME/.ssh
        cd $HOME
        git clone git@github.com:bebert64/nix-configs
      '')
    ];
    by-db-pkgs = { };
  };
}
