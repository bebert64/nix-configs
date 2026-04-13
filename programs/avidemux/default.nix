{ pkgs, config, ... }:
let
  ws = config.byDb.ws;
in
{
  home.packages = [ pkgs.avidemux ];
  wayland.windowManager.sway.config = {
    assigns = {
      "\"${ws."11"}\"" = [ { class = "avidemux"; } ];
    };
  };
}
