{ colors, script-playerctl }:
{
  "module/i3" = {
    type = "internal/i3";

    strip-wsnumbers = true;
    pin-workspaces = true;
    enable-scroll = false;

    format = "<label-state><label-mode>";

    label = {
      mode = {
        background = "${colors.shade6}";
        padding = 2;
      };

      focused = {
        text = "%name%";
        background = "${colors.shade4}";
        padding = 2;
      };

      urgent = {
        text = "%name%";
        background = "${colors.alert}";
        padding = 2;
      };

      unfocused = {
        text = "%name%";
        background = "${colors.shade6}";
        padding = 2;
      };

      visible = {
        text = "%name%";
        background = "${colors.shade6}";
        padding = 2;
      };
    };

  };
  "module/sep_i3" = {
    type = "custom/text";
    content = " ";
    content-font = 1;
    content-background = "${colors.shade6}";
  };

  # ; #######################
  # ;
  # ; Middle
  # ;
  # ; #######################

  "module/name" = {
    type = "custom/text";
    content = "   Don Beberto's";
    margin-right = 20;

  };

  "module/strawberry" = {
    type = "custom/script";
    exec = "${script-playerctl}/bin/playerctl-polybar";
    interval = 0.5;

  };

  "module/sep_central" = {
    type = "custom/text";
    content = "      •      ";
    content-font = 1;
  };

  # ; #######################
  # ;
  # ; Right
  # ;
  # ; #######################

  "module/battery" = {
    type = "internal/battery";

    battery = "BAT1";
    adapter = "ACAD";

    label-full = "%percentage%%";
    format = {
      full = {
        text = "<label-full>";
        prefix = {
          text = "󰂅  ";
          font = 2;
        };
        padding = 1;
        background = "${colors.shade8}";
      };

      charging = {
        text = "<label-full>";
        prefix = {
          text = "󰢝  ";
          font = 2;
        };
        padding = 1;
        background = "${colors.shade8}";
      };

      discharging = {
        text = "<label-full>";
        prefix = {
          text = "󰁾  ";
          font = 2;
        };
        padding = 1;
        background = "${colors.shade8}";
      };

      low = {
        text = "<label-full>";
        prefix = {
          text = "󰁺";
          font = 2;
        };
        padding = 1;
        background = "${colors.shade8}";
        foreground = "${colors.alert}";
      };
    };
  };

  "module/filesystem" = {
    type = "internal/fs";
    interval = 25;
    mount-0 = "/";

    format = {
      mounted = {
        text = "<ramp-capacity> <label-mounted>";
        padding = 1;
        background = "${colors.shade7}";
      };
    };

    ramp = {
      capacity = {
        "0" = "";
        "1" = "";
        "2" = "";
        "3" = "";
        "4" = "";
        "5" = "";
        "6" = "";
      };
    };

    label = {
      mounted = "%free%";
    };
  };

  "module/pulseaudio" = {
    type = "internal/pulseaudio";

    format = {
      volume = {
        text = "<ramp-volume>  <label-volume>";
        padding = 1;
        background = "${colors.shade6}";
      };
      muted = {
        padding = 1;
        background = "${colors.shade6}";
      };
    };

    label = {
      volume = "%percentage:3%%";
      muted = {
        text = "  ";
        font = 2;
      };
    };

    ramp = {
      volume = {
        "0" = " ";
        "1" = " ";
        "2" = " ";
        font = 2;
      };
    };

  };
  "module/memory" = {
    type = "internal/memory";
    interval = 2;
    format = {
      prefix = {
        text = "  ";
        font = 2;
      };
      padding = 1;
      background = "${colors.shade5}";
    };

    label = "%percentage_used:2%%";

  };
  "module/cpu" = {
    type = "internal/cpu";
    interval = 2;
    format-padding = 1;
    format-background = "${colors.shade4}";

    format-prefix = "  ";
    format-prefix-font = 2;
    label = "%percentage:2%%";
  };

  "module/wlan" = {
    type = "internal/network";
    interval = 5;
    interface-type = "wireless";

    label = {
      connected = "%essid%";
      disconnected = {
        text = "󱖣";
        font = 0;
      };
    };

    format = {
      connected = {
        text = "<label-connected>";
        background = "${colors.shade3}";
        padding = 1;
        prefix = {
          text = "  ";
          font = 0;
        };
      };

      disconnected = {
        text = "<label-disconnected>";
        background = "${colors.shade3}";
        padding = 1;
      };
    };
  };

  "module/date" = {
    type = "internal/date";
    interval = 10;
    format = {
      padding = 1;
      background = "${colors.shade2}";
    };

    date = {
      text = "%H:%M";
      alt = "%e %b %Y";
    };
    label = "%date%";
  };
}
