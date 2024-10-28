colors: {
  "bar/mainbar" = {
    width = " 100%";
    height = "24pt";

    background = "${colors.background}";
    foreground = "${colors.foreground}";

    line-size = "3pt";

    font = {
      "0" = "Iosevka Nerd Font:pixelsize=10;3";
      "1" = "Iosevka Nerd Font:style=Medium:size=15;5";
      "2" = "Iosevka Nerd Font:style=Medium:size=40;25";
    };

    modules = {
      left = "left1 i3 sep_i3 left2";
      center = "name sep_central strawberry";
      right = "right7 filesystem right6 pulseaudio right5 memory right4 cpu right2 date right1";
    };

    fixed-center = false;

    cursor = {
      click = "pointer";
      scroll = "ns-resize";
    };

    enable-ipc = true;
  };

  "bar/HDMI-1" = {
    "inherit" = "bar/mainbar";
    monitor = "HDMI-1";

    modules = {
      right = "right7-background filesystem right6 pulseaudio right5 memory right4 cpu right3 wireless wired right2 date right1 tray";
    };
  };

  "bar/HDMI-1-battery" = {
    "inherit" = "bar/mainbar";
    monitor = "HDMI-1";

    modules = {
      right = "right8 battery right7 filesystem right6 pulseaudio right5 memory right4 cpu right3 wireless wired right2 date right1 tray";
    };
  };

  "bar/HDMI-2" = {
    "inherit" = "bar/mainbar";
    monitor = "HDMI-2";

    modules = {
      right = "right7-background filesystem right6 pulseaudio right5 memory right4 cpu right3 wired right2 date right1";
    };
  };

  "bar/eDP-1-tray-on" = {
    "inherit" = "bar/mainbar";
    monitor = "eDP-1";

    modules = {
      right = "right8 battery right7 filesystem right6 pulseaudio right5 memory right4 cpu right3 wireless wired right2 date right1 tray";
    };
  };

  "bar/eDP-1-tray-off" = {
    "inherit" = "bar/mainbar";
    monitor = "eDP-1";

    modules = {
      right = "right8 battery right7 filesystem right6 pulseaudio right5 memory right4 cpu right3 wireless wired right2 date right1";
    };
  };
}
