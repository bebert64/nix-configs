{ config, lib, ... }:
let
  modifier = config.xsession.windowManager.i3.config.modifier;
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

  xsession.windowManager.i3.config.keybindings = lib.mkOptionDefault {
    "${modifier}+Control+f" = "workspace $ws2; exec firefox";
    "${modifier}+Control+s" = "workspace $ws9; exec firefox -P shortcuts https://google.com";
  };
}
