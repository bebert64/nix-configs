{ lib, config, ... }:
let
  cfg = config.by-db;
  exitMode = cfg.i3.exitMode;
in
{
  options.by-db.i3.exitMode = lib.mkOption {
    type = lib.types.str;
    description = "This is a hack to share the value with lock.nix, but is not meant to be overriden";
    default = "Exit: [s]leep, [r]eboot, [p]ower off, [l]ogout";
  };

  config = {
    xsession = {
      enable = true;
      scriptPath = ".hm-xsession";
      numlock.enable = true;
      windowManager.i3 = {
        enable = true;

        config = rec {
          modifier = "Mod4";

          keybindings = lib.mkOptionDefault {
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
            "${modifier}+i" = "workspace $ws11; workspace $ws12";

            # Modes
            "${modifier}+Shift+e" = "mode \"${exitMode}\"";
          };

          startup = [
            {
              command = "i3-msg workspace $ws1;";
              notification = false;
            }
            # https://wiki.archlinux.org/title/GNOME/Keyring#Launching_gnome-keyring-daemon_outside_desktop_environments_(KDE,_GNOME,_XFCE,_...)
            {
              command = "dbus-update-activation-environment --all; gnome-keyring-daemon --start --components=secrets";
              notification = false;
            }
          ]
          ++ lib.optional cfg.wifi.enable {
            command = "nm-applet";
            notification = false;
          }
          ++ lib.optional cfg.bluetooth.enable {
            command = "blueman-applet";
            notification = false;
          };

          window = {
            titlebar = false;
            border = 2;
          };

          modes = {
            ${exitMode} = {
              r = "exec systemctl reboot";
              p = "exec shutdown now";
              l = "exec i3-msg exit";
              Escape = "mode default";
              Return = "mode default";
            };
          };

          # Needed to keep i3bar from being displayed
          bars = [ ];

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
          workspace $ws10 gaps inner 80
          set $ws11 "11:󰸉"
          workspace $ws11 output ${cfg.screens.primary}
          set $ws12 "12:󰸉"
          workspace $ws12 output ${cfg.screens.secondary}
        '';
      };
    };
  };
}
