{ lib, host-specific, ... }:

{
  enable = true;

  config =
    let
      modifier = "Mod4";
      exit_mode = "Exit: [s]leep, [r]eboot, [p]ower off, [l]ogout";
      music_mode = "Music";
    in
    {
      inherit modifier; # Check if possible to remove this line entirely (not sure if it's really necessary)

      menu = "\"rofi -modi drun#window#run -show drun -show-icons\"";

      terminal = "--no-startup-id tilix"; # tilix is not notification-aware so we need the no-startup-id

      keybindings = lib.mkOptionDefault {
        # Volume
        XF86AudioRaiseVolume = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10% && $refresh_i3status";
        XF86AudioLowerVolume = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10% && $refresh_i3status";
        XF86AudioMute = "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle && $refresh_i3status";
        XF86AudioMicMute = "exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle && $refresh_i3status";

        # Workspace definition
        "${modifier}+1" = "workspace number $ws1";
        "${modifier}+2" = "workspace number $ws2";
        "${modifier}+3" = "workspace number $ws3";
        "${modifier}+4" = "workspace number $ws4";
        "${modifier}+5" = "workspace number $ws5";
        "${modifier}+6" = "workspace number $ws6";
        "${modifier}+7" = "workspace number $ws7";
        "${modifier}+8" = "workspace number $ws8";
        "${modifier}+9" = "workspace number $ws9";
        "${modifier}+0" = "workspace number $ws10";

        # Workspace move container to
        "${modifier}+Shift+1" = "move container to workspace number $ws1";
        "${modifier}+Shift+2" = "move container to workspace number $ws2";
        "${modifier}+Shift+3" = "move container to workspace number $ws3";
        "${modifier}+Shift+4" = "move container to workspace number $ws4";
        "${modifier}+Shift+5" = "move container to workspace number $ws5";
        "${modifier}+Shift+6" = "move container to workspace number $ws6";
        "${modifier}+Shift+7" = "move container to workspace number $ws7";
        "${modifier}+Shift+8" = "move container to workspace number $ws8";
        "${modifier}+Shift+9" = "move container to workspace number $ws9";
        "${modifier}+Shift+0" = "move container to workspace number $ws10";

        # Move workspace to different output
        "${modifier}+Mod1+Left" = "move workspace to output left";
        "${modifier}+Mod1+Right" = "move workspace to output right";

        # Used to display empty workspaces, allowing to see the wallpapers
        "${modifier}+i" = "workspace $wse1; workspace $wse2";

        # Lock the screen
        "--release ${modifier}+o" = "exec lock-conky";

        # Modes
        "${modifier}+Shift+e" = "mode \"${exit_mode}\"";
        "${modifier}+m" = "mode \"${music_mode}\"";

        # Starting apps
        "${modifier}+Control+f" = "workspace $ws2; exec firefox";
        "${modifier}+Control+v" = "workspace $ws3; exec code";
        "${modifier}+Control+l" = "workspace $ws4; exec slack";
        "${modifier}+Control+t" = "workspace $ws5; exec thunderbird -P Regular";
        "${modifier}+Control+d" = "workspace $ws6; exec datagrip";
        "${modifier}+Control+r" = "workspace $ws7; exec tilix -p Ranger -e ranger";
        "${modifier}+Control+s" = "workspace $ws9; exec firefox -P shortcuts https://google.com";
        # Maps to the + key on the numpad
        "${modifier}+Control+KP_Add" = "exec gnome-calculator";
      };

      assigns = {
        "$ws3" = [ { class = "Code"; } ];
        "$ws4" = [ { class = "Slack"; } ];
        "$ws5" = [ { class = "thunderbird"; } ];
        "$ws6" = [ { class = "jetbrains-datagrip"; } ];
        "$ws8" = [ { class = "avidemux"; } ];
        "$ws10" = [ { class = "strawberry"; } ];
      };

      bars = [ ];

      startup =
        [
          {
            command = "autorandr --change";
            notification = false;
            always = true;
          }
          { command = "setxkbmap fr"; }
          # https://wiki.archlinux.org/title/GNOME/Keyring#Launching_gnome-keyring-daemon_outside_desktop_environments_(KDE,_GNOME,_XFCE,_...)
          {
            command = "dbus-update-activation-environment --all; gnome-keyring-daemon --start --components=secrets";
            notification = false;
          }
          # Needed if not on nixos, to be removed if not stand alone installtion
          {
            command = "systemctl --user restart picom";
            notification = false;
          }

          {
            command = "udiskie --tray";
            notification = false;
          }
          {
            command = "xidlehook --timer ${
              toString (host-specific.minutes-before-lock or 3 * 60)
            } 'lock-conky' ' ' &";
            notification = false;
          }
          {
            command = "conky -c ${../assets/conky/qclocktwo} -d";
            notification = false;
          }
        ]
        ++ (
          if host-specific.wifi or false then
            [
              {
                command = "nm-applet";
                notification = false;
              }
            ]
          else
            [ ]
        )
        ++ (
          if host-specific.bluetooth or false then
            [
              {
                command = "blueman-applet";
                notification = false;
              }
            ]
          else
            [ ]
        );

      window = {
        titlebar = false;
        border = 2;
      };

      modes = {
        ${exit_mode} = {
          "--release s" = "exec lock-conky -s, mode default";
          "r" = "exec systemctl reboot";
          "p" = "exec shutdown now";
          "l" = "exec i3-msg exit";
          "Escape" = "mode default";
          "Return" = "mode default";
        };
        ${music_mode} = {
          "${modifier}+Left" = " exec playerctl-restart-or-previous";
          "${modifier}+Right" = "exec playerctl next";
          "Left" = "exec playerctl-move - 10";
          "Right" = "exec playerctl-move + 10";
          "Up" = "exec playerctl volume 0.1+";
          "Down" = "exec playerctl volume 0.1-";
          "space" = "exec playerctl play-pause, mode default";
          "s" = "exec playerctl stop, mode default";
          "${modifier}+s" = "exec playerctl -a stop, mode default";
          "l" = "workspace $ws10, exec strawberry, mode default";
          "r" = "exec launch_radios, mode default";
          "${modifier}+m" = "mode default";
          "Escape" = "mode default";
        };
      };

      defaultWorkspace = "$ws1";

      gaps = {
        inner = 4;
      };
    };

  extraConfig = ''
    set $ws1 "1:"
    set $ws2 "2:"
    set $ws3 "3:"
    set $ws4 "4:"
    set $ws5 "5:"
    set $ws6 "6:"
    set $ws7 "7:"
    set $ws8 "8:󰷝"
    set $ws9 "9:"
    set $ws10 "10:"
    set $wse1 " "
    workspace $wse1 output ${host-specific.screens.screen1}
    set $wse2 "  "
    workspace $wse2 output  ${host-specific.screens.screen2}

    workspace $ws10 gaps inner 80
  '';
}
