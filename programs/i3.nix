{ pkgs, lib, monoFont, host-specific, ... }:

{
  enable = true;
  config = let modifier = "Mod4"; in {
    inherit modifier;
    menu = "\"rofi -show combi\"";
    terminal = "--no-startup-id tilix"; # gnome-terminal is not notification-aware so we need the no-startup-id

    startup = [
      { command = "mount -a"; }
      { command = "feh --bg-max --random ~/Wallpapers"; }
      { command = "dbus-update-activation-environment DISPLAY XAUTHORITY WAYLAND_DISPLAY"; notification = false; } # https://wiki.archlinux.org/title/GNOME/Keyring#Launching_gnome-keyring-daemon_outside_desktop_environments_(KDE,_GNOME,_XFCE,_...)
    ];
  };
}
