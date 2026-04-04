{
  lib,
  config,
  pkgs,
  ...
}:
let
  homeManagerBydbConfig = config.byDb;
  exitMode = homeManagerBydbConfig.sway.exitMode;
  jq = "${pkgs.jq}/bin/jq";
  swaymsg = "${pkgs.sway}/bin/swaymsg";
  moveWorkspaceToOutput =
    direction:
    assert direction == "left" || direction == "right";
    "${pkgs.writeShellScript "move-workspace-to-output-${direction}" ''
      set -euo pipefail

      outputs=$(${swaymsg} -t get_outputs | ${jq} -r '[.[] | select(.active)] | sort_by(.rect.x) | .[].name')
      current_output=$(${swaymsg} -t get_workspaces | ${jq} -r '.[] | select(.focused) | .output')

      output_array=()
      current_idx=-1
      idx=0
      while IFS= read -r name; do
        output_array+=("$name")
        if [ "$name" = "$current_output" ]; then
          current_idx=$idx
        fi
        idx=$((idx + 1))
      done <<< "$outputs"

      target_idx=$((current_idx ${if direction == "left" then "- 1" else "+ 1"}))
      if [ "$target_idx" -lt 0 ] || [ "$target_idx" -ge "''${#output_array[@]}" ]; then
        exit 0
      fi

      target_output="''${output_array[$target_idx]}"
      ${swaymsg} move workspace to output "$target_output"

      sleep 0.1
      ${swaymsg} focus output "$target_output"
    ''}";
in
{
  options.byDb.sway.exitMode = lib.mkOption {
    type = lib.types.str;
    internal = true;
    readOnly = true;
    default = "Exit: [s]leep, [r]eboot, [p]ower off, [l]ogout";
  };

  options.byDb.modifier = lib.mkOption {
    type = lib.types.str;
    internal = true;
    readOnly = true;
    default = "Mod4";
  };

  config = {
    wayland.windowManager.sway = {
      enable = true;
      package = pkgs.swayfx;
      checkConfig = false;

      config = rec {
        modifier = "Mod4";

        keybindings = lib.mkOptionDefault {
          # Workspace definition (AZERTY: unshifted keys are &éà"'(-è_ç)
          "${modifier}+ampersand" = "workspace number 1";
          "${modifier}+eacute" = "workspace number 2";
          "${modifier}+quotedbl" = "workspace number 3";
          "${modifier}+apostrophe" = "workspace number 4";
          "${modifier}+parenleft" = "workspace number 5";
          "${modifier}+minus" = "workspace number 6";
          "${modifier}+egrave" = "workspace number 7";
          "${modifier}+underscore" = "workspace number 8";
          "${modifier}+ccedilla" = "workspace number 9";
          "${modifier}+agrave" = "workspace number 10";
          "${modifier}+Ctrl+ampersand" = "workspace number 11";
          "${modifier}+Ctrl+eacute" = "workspace number 12";
          "${modifier}+Ctrl+quotedbl" = "workspace number 13";
          "${modifier}+Ctrl+apostrophe" = "workspace number 14";
          "${modifier}+Ctrl+parenleft" = "workspace number 15";
          "${modifier}+Ctrl+minus" = "workspace number 16";
          "${modifier}+Ctrl+egrave" = "workspace number 17";
          "${modifier}+Ctrl+underscore" = "workspace number 18";
          "${modifier}+Ctrl+ccedilla" = "workspace number 19";
          "${modifier}+Ctrl+agrave" = "workspace number 20";

          # Workspace move container to
          "${modifier}+Shift+ampersand" = "move container to workspace number 1";
          "${modifier}+Shift+eacute" = "move container to workspace number 2";
          "${modifier}+Shift+quotedbl" = "move container to workspace number 3";
          "${modifier}+Shift+apostrophe" = "move container to workspace number 4";
          "${modifier}+Shift+parenleft" = "move container to workspace number 5";
          "${modifier}+Shift+minus" = "move container to workspace number 6";
          "${modifier}+Shift+egrave" = "move container to workspace number 7";
          "${modifier}+Shift+underscore" = "move container to workspace number 8";
          "${modifier}+Shift+ccedilla" = "move container to workspace number 9";
          "${modifier}+Shift+agrave" = "move container to workspace number 10";
          "${modifier}+Shift+Ctrl+ampersand" = "move container to workspace number 11";
          "${modifier}+Shift+Ctrl+eacute" = "move container to workspace number 12";
          "${modifier}+Shift+Ctrl+quotedbl" = "move container to workspace number 13";
          "${modifier}+Shift+Ctrl+apostrophe" = "move container to workspace number 14";
          "${modifier}+Shift+Ctrl+parenleft" = "move container to workspace number 15";
          "${modifier}+Shift+Ctrl+minus" = "move container to workspace number 16";
          "${modifier}+Shift+Ctrl+egrave" = "move container to workspace number 17";
          "${modifier}+Shift+Ctrl+underscore" = "move container to workspace number 18";
          "${modifier}+Shift+Ctrl+ccedilla" = "move container to workspace number 19";
          "${modifier}+Shift+Ctrl+agrave" = "move container to workspace number 20";

          "${modifier}+Mod1+Left" = "exec ${moveWorkspaceToOutput "left"}";
          "${modifier}+Mod1+Right" = "exec ${moveWorkspaceToOutput "right"}";

          # Used to display empty workspaces, allowing to see the wallpapers
          "${modifier}+i" = "workspace number 19; workspace number 20";

          # Modes
          "${modifier}+Shift+e" = "mode \"${exitMode}\"";
        };

        startup = [
          { command = "swaymsg workspace number 1"; }
          # https://wiki.archlinux.org/title/GNOME/Keyring#Launching_gnome-keyring-daemon_outside_desktop_environments_(KDE,_GNOME,_XFCE,_...)
          { command = "dbus-update-activation-environment --all; gnome-keyring-daemon --start --components=secrets"; }
          { command = "swww-daemon"; }
        ]
        ++ lib.optional homeManagerBydbConfig.wifi.enable { command = "nm-applet"; }
        ++ lib.optional homeManagerBydbConfig.bluetooth.enable { command = "blueman-applet"; };

        window = {
          titlebar = false;
          border = 2;
        };

        modes = {
          ${exitMode} = {
            r = "exec systemctl reboot";
            p = "exec shutdown now";
            l = "exec swaymsg exit";
            Escape = "mode default";
            Return = "mode default";
          };
        };

        # Needed to keep the default bar from being displayed (we use waybar)
        bars = [ ];

        input = {
          "type:keyboard" = {
            xkb_layout = "fr";
          };
        };

        gaps = {
          inner = 4;
        };
      };

      extraConfig = ''
        set $ws1 "1:"
        set $ws2 "2:"
        set $ws3 "3:"
        set $ws4 "4:"
        set $ws5 "5:"
        set $ws6 "6:"
        set $ws7 "7:"
        set $ws8 "8:"
        set $ws9 "9:󱓞"
        set $ws10 "10:"
        workspace $ws10 gaps inner 80
        set $ws11 "11:󰷝"
        set $ws12 "12:"
        set $ws13 "13:󰖔"
        set $ws14 "14"
        set $ws15 "15"
        set $ws16 "16"
        set $ws17 "17"
        set $ws18 "18"
        set $ws19 "19:󰸉"
        workspace $ws19 output ${homeManagerBydbConfig.screens.primary}
        set $ws20 "20:󰸉"
        workspace $ws20 output ${homeManagerBydbConfig.screens.secondary}

        blur enable
        blur_passes 2
        blur_radius 5
        corner_radius 8
        shadows enable
        default_dim_inactive 0.1
      '';
    };
  };
}
