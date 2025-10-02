{ config, ... }:
{
  services.polybar.settings =
    let
      colors = config.by-db.polybar.colors;
    in
    {
      mainbar = {
        width = " 100%";
        height = "24pt";

        background = "${colors.background}";
        foreground = "${colors.foreground}";

        line-size = "3pt";

        font = {
          "0" = "Iosevka Nerd Font:style=Medium:size=10;3";
          "1" = "Iosevka Nerd Font:style=Medium:size=13;4";
          "2" = "Iosevka Nerd Font:style=Medium:size=40;25";
        };

        modules = {
          left = "left1 i3 sep_i3 left2";
        };

        fixed-center = false;

        cursor = {
          click = "pointer";
          scroll = "ns-resize";
        };

        enable-ipc = true;
      };

      HDMI = {
        "inherit" = "mainbar";
        modules = {
          center = "playerctl-full";
        };
      };

      "bar/HDMI-0" = {
        "inherit" = "HDMI";
        monitor = "HDMI-0";
        modules = {
          right = "right7-background filesystem right6 pulseaudio headphones_or_speaker right5 memory right4 cpu right3 wireless wired right2 date right1 tray";
        };
      };

      "bar/HDMI-1" = {
        "inherit" = "HDMI";
        monitor = "HDMI-1";
        modules = {
          right = "right7-background filesystem right6 pulseaudio headphones_or_speaker right5 memory right4 cpu right3 wireless wired right2 date right1 tray";
        };
      };

      "bar/HDMI-1-battery" = {
        "inherit" = "HDMI";
        monitor = "HDMI-1";
        modules = {
          right = "right8 battery right7 filesystem right6 pulseaudio headphones_or_speaker right5 memory right4 cpu right3 wireless wired right2 date right1 tray";
        };
      };

      "bar/HDMI-2" = {
        "inherit" = "HDMI";
        monitor = "HDMI-2";
        modules = {
          right = "right7-background filesystem right6 pulseaudio headphones_or_speaker right5 memory right4 cpu right3 wired right2 date right1";
        };
      };

      EDP = {
        "inherit" = "mainbar";
        modules = {
          center = "playerctl-mini";
        };
      };

      "bar/eDP-1-tray-on" = {
        "inherit" = "EDP";
        monitor = "eDP-1";
        modules = {
          right = "right8 battery right7 filesystem right6 pulseaudio headphones_or_speaker right5 memory right4 cpu right3 wireless wired right2 date right1 tray";
        };
      };

      "bar/eDP-1-tray-on-on-hdmi" = {
        "inherit" = "EDP";
        monitor = "HDMI-1";
        modules = {
          right = "right8 battery right7 filesystem right6 pulseaudio headphones_or_speaker right5 memory right4 cpu right3 wireless wired right2 date right1 tray";
        };
      };

      "bar/eDP-1-tray-off" = {
        "inherit" = "EDP";
        monitor = "eDP-1";
        modules = {
          right = "right8 battery right7 filesystem right6 pulseaudio headphones_or_speaker right5 memory right4 cpu right3 wireless wired right2 date right1";
        };
      };

      "bar/eDP-1-tray-off-on-hdmi1" = {
        "inherit" = "EDP";
        monitor = "HDMI-1";
        modules = {
          right = "right8 battery right7 filesystem right6 pulseaudio headphones_or_speaker right5 memory right4 cpu right3 wireless wired right2 date right1";
        };
      };
    };
}
