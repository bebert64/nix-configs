{
  pkgs,
  config,
  lib,
  ...
}:
let
  modifier = config.byDb.modifier;
  ws = config.byDb.ws;
in
{
  home.packages = [ pkgs.ferdium ];

  wayland.windowManager.sway.config = {
    assigns = {
      "\"${ws."5"}\"" = [
        { class = "ferdium"; }
        { class = "Ferdium"; }
      ];
    };
    keybindings = lib.mkOptionDefault { "${modifier}+Control+t" = "workspace \"${ws."5"}\"; exec ferdium"; };
  };
}
