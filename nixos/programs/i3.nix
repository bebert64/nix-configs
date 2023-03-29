{ pkgs, lib, monoFont, host-specific, ... }:

{
  enable = true;
  config = let modifier = "Mod4"; in {
    inherit modifier;
    menu = "\"rofi -show combi\"";
    terminal = "--no-startup-id tilix"; # gnome-terminal is not notification-aware so we need the no-startup-id

    keybindings = lib.mkOptionDefault {
      "${modifier}+Control+r" = "workspace 7; exec tilix -p Ranger -e ranger";
    };

    startup = [
      { command = "mount -a"; }
      { command = "feh --bg-max --random ~/Wallpapers"; }
      { command = "dconf load /com/gexperts/Tilix/ < tilix.dconf"; } # load terminal theme
      # https://wiki.archlinux.org/title/GNOME/Keyring#Launching_gnome-keyring-daemon_outside_desktop_environments_(KDE,_GNOME,_XFCE,_...)
      { command = "dbus-update-activation-environment DISPLAY XAUTHORITY WAYLAND_DISPLAY"; notification = false; } 
       # Loads radios in straberry. Would have been better as a "rebuild only" script, but coulnd't make it work
       # and it's fast enough, so it doesn't really slow down i3's starting
      { command = "steam-run /home/romain/scripts/strawberry/strawberry-add-playlist /home/romain/scripts/strawberry/radios.json"; }
    ];
  };
}
