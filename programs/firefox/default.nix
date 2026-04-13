{ config, lib, ... }:
let
  inherit (config.byDb) modifier;
  inherit (config.byDb) ws;
in
{
  programs.firefox = {
    enable = true;
    profiles = {
      default = {
        id = 0;
        name = "default";
        isDefault = true;
      };
      shortcuts = {
        id = 1;
        name = "shortcuts";
      };
    };
  };

  wayland.windowManager.sway.config = {
    keybindings = lib.mkOptionDefault {
      "${modifier}+Control+f" = "workspace \"${ws."2"}\"; exec firefox";
      "${modifier}+Control+s" =
        "workspace \"${ws."12"}\"; exec firefox -P shortcuts --class shortcuts https://google.com";
    };
    assigns = {
      "\"${ws."2"}\"" = [ { class = "firefox"; } ];
      "\"${ws."12"}\"" = [ { class = "shortcuts"; } ];
    };
  };
}
