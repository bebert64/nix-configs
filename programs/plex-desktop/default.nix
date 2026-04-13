{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (config.byDb) modifier;
  inherit (config.byDb) ws;
in
{
  home.packages = [ pkgs.plex-desktop ];
  wayland.windowManager.sway.config = {
    assigns = {
      "\"${ws."8"}\"" = [ { class = "Plex"; } ];
    };
    keybindings = lib.mkOptionDefault {
      "${modifier}+Control+p" = "workspace \"${ws."8"}\"; exec plex-desktop";
    };
  };
}
