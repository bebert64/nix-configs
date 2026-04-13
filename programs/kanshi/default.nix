{ config, lib, ... }:

# If kanshi ever enters an event loop when plugging/unplugging HDMI (it did on
# X11 with autorandr), re-add per-profile tracking to detect no-op switches:
#   profile.exec = [
#     ...existing exec lines...
#     ''sh -c "echo PROFILE_NAME > ${config.home.homeDirectory}/.config/kanshi/current"''
#   ];
# Then guard with a preswitch check that skips if $current == target profile.
# Also update SaveKanshiConfig to emit the echo line again (removed at the same time).

{
  services.kanshi = {
    enable = true;
    settings = [
      {
        profile.name = "bureau";
        profile.outputs = [
          {
            criteria = "HDMI-A-2";
            mode = "2560x1440";
            position = "0,0";
          }
          {
            criteria = "HDMI-A-1";
            mode = "2560x1440";
            position = "2560,0";
          }
        ];
        profile.exec = [
          "systemctl --user restart waybar"
          "systemctl --user restart wallpapers-manager"
        ];
      }
      {
        profile.name = "stockly-romainc";
        profile.outputs = [
          {
            criteria = "eDP-1";
            mode = "1920x1080";
            position = "0,0";
            status = "enable";
          }
        ];
        profile.exec = [
          "systemctl --user restart waybar"
          "systemctl --user restart wallpapers-manager"
        ];
      }
      {
        profile.name = "stockly-romainc-bureau";
        profile.outputs = [
          {
            criteria = "eDP-1";
            mode = "1920x1080";
            position = "0,360";
          }
          {
            criteria = "HDMI-A-1";
            mode = "2560x1440";
            position = "1920,0";
          }
        ];
        profile.exec = [
          "systemctl --user restart waybar"
          "systemctl --user restart wallpapers-manager"
        ];
      }
      {
        profile.name = "stockly-bureau-1";
        profile.outputs = [
          {
            criteria = "eDP-1";
            mode = "1920x1080@60Hz";
            position = "0,0";
          }
          {
            criteria = "HDMI-A-1";
            mode = "2560x1440";
            position = "1920,0";
          }
        ];
        profile.exec = [
          "systemctl --user restart waybar"
          "systemctl --user restart wallpapers-manager"
        ];
      }
      {
        profile.name = "stockly-tom";
        profile.outputs = [
          {
            criteria = "HDMI-A-1";
            mode = "2560x1440";
            position = "0,0";
          }
          {
            criteria = "eDP-1";
            mode = "1920x1080";
            position = "2560,0";
          }
        ];
        profile.exec = [
          "systemctl --user restart waybar"
          "systemctl --user restart wallpapers-manager"
        ];
      }
      {
        profile.name = "zizou";
        profile.outputs = [
          {
            criteria = "eDP-1";
            mode = "1920x1080";
            position = "0,0";
          }
          {
            criteria = "HDMI-A-1";
            mode = "2560x1440";
            position = "1920,0";
          }
        ];
        profile.exec = [
          "systemctl --user restart waybar"
          "systemctl --user restart wallpapers-manager"
        ];
      }
      {
        profile.name = "factory-s";
        profile.outputs = [
          {
            criteria = "eDP-1";
            mode = "1920x1080";
            position = "0,360";
          }
          {
            criteria = "HDMI-A-1";
            mode = "2560x1440";
            position = "1920,0";
          }
        ];
        profile.exec = [
          "systemctl --user restart waybar"
          "systemctl --user restart wallpapers-manager"
        ];
      }
      {
        profile.name = "salon0";
        profile.outputs = [
          {
            criteria = "HDMI-A-0";
            mode = "1920x1080";
            position = "0,0";
          }
        ];
        profile.exec = [
          "systemctl --user restart waybar"
          "systemctl --user restart wallpapers-manager"
        ];
      }
      {
        profile.name = "salon2";
        profile.outputs = [
          {
            criteria = "HDMI-A-2";
            mode = "1920x1080";
            position = "0,0";
          }
        ];
        profile.exec = [
          "systemctl --user restart waybar"
          "systemctl --user restart wallpapers-manager"
        ];
      }
      {
        profile.name = "grenoble-yohan";
        profile.outputs = [
          {
            criteria = "eDP-1";
            mode = "1920x1080";
            position = "0,0";
          }
          {
            criteria = "HDMI-A-1";
            mode = "1920x1080";
            position = "1920,0";
          }
        ];
        profile.exec = [
          "systemctl --user restart waybar"
          "systemctl --user restart wallpapers-manager"
        ];
      }
    ];
  };

  wayland.windowManager.sway.config.keybindings = lib.mkOptionDefault {
    "${config.byDb.modifier}+Shift+a" = "exec kanshictl reload";
  };
}
