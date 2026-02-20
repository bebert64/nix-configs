{
  pkgs,
  lib,
  config,
  ...
}:
let
  homeDir = config.home.homeDirectory;
in
{
  home = {
    packages = [ pkgs.udiskie ];
    activation = {
      symlinkUsbMountPoint = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p ${homeDir}/mnt/
        ln -sfT /run/media/${config.byDb.user.name} ${homeDir}/mnt/usb
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
