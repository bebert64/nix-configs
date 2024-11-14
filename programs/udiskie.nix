{ pkgs, lib, config, ... }:
{
  config.home = {
    packages = [
      pkgs.udiskie
    ];
    activation = {
      symlinkUsbMountPoint = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p $HOME/mnt/
        ln -sf -T /run/media/${config.by-db.username} $HOME/mnt/usb
      '';
    };
  };
}
