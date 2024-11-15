{ pkgs, ... }:
{
  config.home = {
    packages = [ pkgs.picom-next ];
    file = {
      ".config/picom.conf".source = ./picom.conf;
    };
  };
}
