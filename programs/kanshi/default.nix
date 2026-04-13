{ config, lib, ... }:

# If kanshi ever enters an event loop when plugging/unplugging HDMI (it did on
# X11 with autorandr), re-add per-profile tracking to detect no-op switches:
#   profile.exec = [
#     ...existing exec lines...
#     ''sh -c "echo PROFILE_NAME > ${config.home.homeDirectory}/.config/kanshi/current"''
#   ];
# Then guard with a preswitch check that skips if $current == target profile.
# Also update SaveKanshiConfig to emit the echo line again (removed at the same time).

let
  commonExec = [
    "systemctl --user restart waybar"
    "systemctl --user restart wallpapers-manager"
  ];
in
{
  services.kanshi = {
    enable = true;
    settings = [
      {
        profile = {
          name = "bureau";
          outputs = [
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
          exec = commonExec;
        };
      }
      {
        profile = {
          name = "stockly-romainc";
          outputs = [
            {
              criteria = "eDP-1";
              mode = "1920x1080";
              position = "0,0";
              status = "enable";
            }
          ];
          exec = commonExec;
        };
      }
      {
        profile = {
          name = "stockly-romainc-bureau";
          outputs = [
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
          exec = commonExec;
        };
      }
      {
        profile = {
          name = "stockly-bureau-1";
          outputs = [
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
          exec = commonExec;
        };
      }
      {
        profile = {
          name = "stockly-tom";
          outputs = [
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
          exec = commonExec;
        };
      }
      {
        profile = {
          name = "zizou";
          outputs = [
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
          exec = commonExec;
        };
      }
      {
        profile = {
          name = "factory-s";
          outputs = [
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
          exec = commonExec;
        };
      }
      {
        profile = {
          name = "salon0";
          outputs = [
            {
              criteria = "HDMI-A-0";
              mode = "1920x1080";
              position = "0,0";
            }
          ];
          exec = commonExec;
        };
      }
      {
        profile = {
          name = "salon2";
          outputs = [
            {
              criteria = "HDMI-A-2";
              mode = "1920x1080";
              position = "0,0";
            }
          ];
          exec = commonExec;
        };
      }
      {
        profile = {
          name = "grenoble-yohan";
          outputs = [
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
          exec = commonExec;
        };
      }
    ];
  };

  wayland.windowManager.sway.config.keybindings = lib.mkOptionDefault {
    "${config.byDb.modifier}+Shift+a" = "exec kanshictl reload";
  };
}
