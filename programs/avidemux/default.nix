{ pkgs, ... }:
{
  home.packages = [ pkgs.avidemux ];
  wayland.windowManager.sway.config = {
    assigns = {
      "$ws11" = [ { class = "avidemux"; } ];
    };
  };
}
