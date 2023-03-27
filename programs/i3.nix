{ pkgs, lib, monoFont, host-specific, ... }:

{
  enable = true;
  config = let modifier = "Mod4"; in {
    inherit modifier;
    menu = "\"rofi -show combi\"";
    terminal = "--no-startup-id gnome-terminal"; # gnome-terminal is not notification-aware so we need the no-startup-id

    startup = [
      { command = "mount -a"; }
      { command = "feh --bg-max --random ~/Wallpapers"; }
    ];
  };
}
