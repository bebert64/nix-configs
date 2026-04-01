{
  services.dunst = {
    enable = true;
    settings = {
      global = {
        origin = "top-right";
        offset = "10x10";
        gap_size = 5;
        font = "monospace 10";
        corner_radius = 6;
        frame_width = 1;
        frame_color = "#414868";
        separator_color = "frame";
        padding = 100;
        horizontal_padding = 100;
      };

      urgency_low = {
        background = "#1a1b26";
        foreground = "#c0caf5";
        timeout = 5;
      };

      urgency_normal = {
        background = "#1a1b26";
        foreground = "#c0caf5";
        timeout = 8;
      };

      urgency_critical = {
        background = "#1a1b26";
        foreground = "#f7768e";
        frame_color = "#f7768e";
        timeout = 0;
      };
    };
  };
}
