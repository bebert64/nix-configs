{ pkgs, ... }:
{
  home = {
    # I'm experiencing issue with memory leak (using all the RAM) with picom
    # so I'm using picom-next instead
    packages = [ pkgs.picom-next ];
    file = {
      ".config/picom.conf".source = ./picom.conf;
    };
  };

  xsession.windowManager.i3.config.startup = [
    {
      command = "picom";
      notification = false;
    }
  ];
}
