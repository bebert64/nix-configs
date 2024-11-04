{ colors, scripts }:
{
  "module/i3" = {
    type = "internal/i3";

    strip-wsnumbers = true;
    pin-workspaces = true;
    enable-scroll = false;

    format = {
      text = "<label-state><label-mode>";
      offset = -10;
    };

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
    format = {
      text = " ";
      background = "${colors.shade6}";
    };
  };

  # ; #######################
  # ;
  # ; Middle
  # ;
  # ; #######################

  "player-ctl" = {
    type = "custom/script";
    interval = 0.5;
  };

  "module/playerctl-full" = {
    "inherit" = "player-ctl";
    exec = "${scripts.cmd-bar-and-display-title}/bin/playerctl-cmd-bar-and-display-title";
    label = "Don Beberto's      •      %output%";
  };

  "module/playerctl-mini" = {
    "inherit" = "player-ctl";
    exec = "${scripts.display-title-or-no-music}/bin/playerctl-display-title-or-no-music";
    label = "%output:0:70%";
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

    format = {
      full = {
        prefix = {
          text = "󰂅  ";
          font = 2;
        };
        padding = 1;
        background = "${colors.shade8}";
      };

      charging = {
        prefix = {
          text = "󰢝  ";
          font = 2;
        };
        padding = 1;
        background = "${colors.shade8}";
      };

      discharging = {
        prefix = {
          text = "󰁾  ";
          font = 2;
        };
        padding = 1;
        background = "${colors.shade8}";
      };

      low = {
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
        text = "%{T2}<ramp-capacity>%{T-} <label-mounted>";
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
        "1" = {
          text = " ";
          weight = 10;
        };
        "2" = " ";
        font = 2;
      };
    };
  };

  "module/headphones_or_speaker" = {
    type = "custom/script";
    exec = "${scripts.headphones-or-speaker-icon}/bin/headphones-or-speaker-icon";
    format = {
      background = "${colors.shade6}";
      font = 2;
      padding = 1;
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

    label = "%percentage_used:3%%";

  };
  "module/cpu" = {
    type = "internal/cpu";
    interval = 2;
    format = {
      padding = 1;
      background = "${colors.shade4}";
      prefix = {
        text = "  ";
        font = 2;
      };
    };
    label = "%percentage:3%%";
  };

  "internet" = {
    type = "internal/network";
    interval = 1;
    speed-unit = "o/s";
    label = {
      connected = "%{T2} %{T-}%downspeed:9%  %{T2} %{T-}%upspeed:9%";
    };
    format = {
      connected = {
        background = "${colors.shade3}";
        padding = 1;
      };
      disconnected = {
        background = "${colors.shade3}";
        padding = 1;
      };
    };

  };

  "module/wireless" = {
    "inherit" = "internet";
    interface-type = "wireless";

    format = {
      connected = {
        text = "%{T2}<ramp-signal>  %{T-}<label-connected>";
      };

      disconnected = {
        text = "󱖣";
        font = 2;
      };
    };

    ramp = {
      signal = {
        "0" = "󰤯";
        "1" = "󰤟";
        "2" = "󰤢";
        "3" = "󰤥";
        "4" = "󰤨";
      };
    };
  };

  "module/wired" = {
    "inherit" = "internet";
    interface-type = "wired";

    format = {
      connected = {
        text = "<label-connected>";
        prefix = {
          text = "  ";
          font = 2;
        };
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

  "module/tray" = {
    type = "internal/tray";
    tray = {
      spacing = 8;
      size = 20;
      background = "${colors.shade1}";
    };
    format = {
      offset = -10;
      padding = 2;
      background = "${colors.shade1}";
    };

  };
}
