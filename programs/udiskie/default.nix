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
        mkdir -p ${config.home.homeDirectory}/mnt/
        ln -sfT /run/media/${config.byDb.user.name} ${config.home.homeDirectory}/mnt/usb
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
