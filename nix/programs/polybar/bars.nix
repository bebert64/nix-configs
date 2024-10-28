colors: {
  "bar/mainbar" = {
    width = " 100%";
    height = "24pt";
    radius = 0;

    background = "${colors.background}";
    foreground = "${colors.foreground}";

    line-size = "3pt";

    border = {
      size = "0pt";
      color = "#00000000";
    };

    padding = {
      left = 0;
      right = 0;
    };

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
      left = "left1 sep_i3 i3 sep_i3 left2";
      center = "name sep_central strawberry";
      right = "right7 filesystem right6 pulseaudio right5 memory right4 cpu right2 date right1 tray";
    };
  };

  "bar/HDMI-2" = {
    "inherit" = "bar/mainbar";
    monitor = "HDMI-2";

    modules = {
      left = "left1 sep_i3 i3 sep_i3 left2";
      center = "name sep_central strawberry";
      right = "right7 filesystem right6 pulseaudio right5 memory right4 cpu right2 date right1";
    };
  };
}
