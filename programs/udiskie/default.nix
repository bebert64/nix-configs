{
  pkgs,
  lib,
  config,
  ...
}:
{
  home = {
    packages = [ pkgs.udiskie ];
    activation = {
      symlinkUsbMountPoint = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p $HOME/mnt/
        ln -sf -T /run/media/${config.by-db.user.name} $HOME/mnt/usb
      '';
    };
  };
  xsession.windowManager.i3.config.startup = [
    {
      command = "udiskie --tray";
      notification = false;
    }
  ];
}
