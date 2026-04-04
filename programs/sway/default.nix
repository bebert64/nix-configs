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
  ws = {
    "1" = "1:";
    "2" = "2:";
    "3" = "3:";
    "4" = "4:";
    "5" = "5:";
    "6" = "6:";
    "7" = "7:";
    "8" = "8:";
    "9" = "9:󱓞";
    "10" = "10:";
    "11" = "11:󰷝";
    "12" = "12:";
    "13" = "13:󰖔";
    "14" = "14";
    "15" = "15";
    "16" = "16";
    "17" = "17";
    "18" = "18";
    "19" = "19:󰸉";
    "20" = "20:󰸉";
  };
  showWallpapers =
    let
      primary = homeManagerBydbConfig.screens.primary;
      secondary = homeManagerBydbConfig.screens.secondary;
    in
    "${pkgs.writeShellScript "show-wallpapers" ''
      set -euo pipefail
      ${swaymsg} focus output ${primary}
      ${swaymsg} workspace "${ws."19"}"
      ${lib.optionalString (secondary != "") ''
        ${swaymsg} focus output ${secondary}
        ${swaymsg} workspace "${ws."20"}"
      ''}
    ''}";
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
          "${modifier}+ampersand" = "workspace \"${ws."1"}\"";
          "${modifier}+eacute" = "workspace \"${ws."2"}\"";
          "${modifier}+quotedbl" = "workspace \"${ws."3"}\"";
          "${modifier}+apostrophe" = "workspace \"${ws."4"}\"";
          "${modifier}+parenleft" = "workspace \"${ws."5"}\"";
          "${modifier}+minus" = "workspace \"${ws."6"}\"";
          "${modifier}+egrave" = "workspace \"${ws."7"}\"";
          "${modifier}+underscore" = "workspace \"${ws."8"}\"";
          "${modifier}+ccedilla" = "workspace \"${ws."9"}\"";
          "${modifier}+agrave" = "workspace \"${ws."10"}\"";
          "${modifier}+Ctrl+ampersand" = "workspace \"${ws."11"}\"";
          "${modifier}+Ctrl+eacute" = "workspace \"${ws."12"}\"";
          "${modifier}+Ctrl+quotedbl" = "workspace \"${ws."13"}\"";
          "${modifier}+Ctrl+apostrophe" = "workspace \"${ws."14"}\"";
          "${modifier}+Ctrl+parenleft" = "workspace \"${ws."15"}\"";
          "${modifier}+Ctrl+minus" = "workspace \"${ws."16"}\"";
          "${modifier}+Ctrl+egrave" = "workspace \"${ws."17"}\"";
          "${modifier}+Ctrl+underscore" = "workspace \"${ws."18"}\"";
          "${modifier}+Ctrl+ccedilla" = "workspace \"${ws."19"}\"";
          "${modifier}+Ctrl+agrave" = "workspace \"${ws."20"}\"";

          # Workspace move container to
          "${modifier}+Shift+ampersand" = "move container to workspace \"${ws."1"}\"";
          "${modifier}+Shift+eacute" = "move container to workspace \"${ws."2"}\"";
          "${modifier}+Shift+quotedbl" = "move container to workspace \"${ws."3"}\"";
          "${modifier}+Shift+apostrophe" = "move container to workspace \"${ws."4"}\"";
          "${modifier}+Shift+parenleft" = "move container to workspace \"${ws."5"}\"";
          "${modifier}+Shift+minus" = "move container to workspace \"${ws."6"}\"";
          "${modifier}+Shift+egrave" = "move container to workspace \"${ws."7"}\"";
          "${modifier}+Shift+underscore" = "move container to workspace \"${ws."8"}\"";
          "${modifier}+Shift+ccedilla" = "move container to workspace \"${ws."9"}\"";
          "${modifier}+Shift+agrave" = "move container to workspace \"${ws."10"}\"";
          "${modifier}+Shift+Ctrl+ampersand" = "move container to workspace \"${ws."11"}\"";
          "${modifier}+Shift+Ctrl+eacute" = "move container to workspace \"${ws."12"}\"";
          "${modifier}+Shift+Ctrl+quotedbl" = "move container to workspace \"${ws."13"}\"";
          "${modifier}+Shift+Ctrl+apostrophe" = "move container to workspace \"${ws."14"}\"";
          "${modifier}+Shift+Ctrl+parenleft" = "move container to workspace \"${ws."15"}\"";
          "${modifier}+Shift+Ctrl+minus" = "move container to workspace \"${ws."16"}\"";
          "${modifier}+Shift+Ctrl+egrave" = "move container to workspace \"${ws."17"}\"";
          "${modifier}+Shift+Ctrl+underscore" = "move container to workspace \"${ws."18"}\"";
          "${modifier}+Shift+Ctrl+ccedilla" = "move container to workspace \"${ws."19"}\"";
          "${modifier}+Shift+Ctrl+agrave" = "move container to workspace \"${ws."20"}\"";

          "${modifier}+Mod1+Left" = "exec ${moveWorkspaceToOutput "left"}";
          "${modifier}+Mod1+Right" = "exec ${moveWorkspaceToOutput "right"}";

          # Used to display empty workspaces, allowing to see the wallpapers
          "${modifier}+i" = "exec ${showWallpapers}";

          # Modes
          "${modifier}+Shift+e" = "mode \"${exitMode}\"";
        };

        startup = [
          { command = "swaymsg rename workspace to \"${ws."1"}\""; }
          # https://wiki.archlinux.org/title/GNOME/Keyring#Launching_gnome-keyring-daemon_outside_desktop_environments_(KDE,_GNOME,_XFCE,_...)
          { command = "dbus-update-activation-environment --all; gnome-keyring-daemon --start --components=secrets"; }
          { command = "swww-daemon"; }
          # kanshi starts before Sway is fully ready; restart it once the compositor is up
          { command = "systemctl --user restart kanshi"; always = true; }
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
        for_window [app_id="kitty"] border normal 2

        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (n: v: "set $ws${n} \"${v}\"") ws)}

        workspace "${ws."10"}" gaps inner 80
        workspace "${ws."19"}" output ${homeManagerBydbConfig.screens.primary}
        ${lib.optionalString (homeManagerBydbConfig.screens.secondary != "") "workspace \"${ws."20"}\" output ${homeManagerBydbConfig.screens.secondary}"}

        blur enable
        blur_passes 2
        blur_radius 5
        corner_radius 8
        shadows enable
        default_dim_inactive 0.1
        layer_effects "conky_namespace" blur enable
      '';
    };
  };
}
