{ config, lib, ... }:
let
  modifier = config.byDb.modifier;
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
      "${modifier}+Control+f" = "workspace $ws2; exec firefox";
      "${modifier}+Control+s" =
        "workspace $ws12; exec firefox -P shortcuts --class shortcuts https://google.com";
    };
    assigns = {
      "$ws2" = [ { class = "firefox"; } ];
      "$ws12" = [ { class = "shortcuts"; } ];
    };
  };
}
