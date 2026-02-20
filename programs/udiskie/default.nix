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
        mkdir -p ${config.byDb.paths.home}/mnt/
        ln -sfT /run/media/${config.byDb.user.name} ${config.byDb.paths.home}/mnt/usb
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
