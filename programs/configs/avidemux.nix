{ pkgs, ... }:
{
  home.packages = [ pkgs.avidemux ];
  xsession.windowManager.i3.config = {
    assigns = {
      "$ws8" = [ { class = "avidemux"; } ];
    };
  };
}
