{ pkgs, config, ... }:
let
  inherit (config.byDb) ws;
in
{
  home.packages = [ pkgs.avidemux ];
  wayland.windowManager.sway.config = {
    assigns = {
      "\"${ws."11"}\"" = [ { class = "avidemux"; } ];
    };
  };
}
