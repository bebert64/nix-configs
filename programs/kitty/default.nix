{ ... }:
{
  programs.kitty = {
    enable = true;
    font = {
      name = "Iosevka Nerd Font";
      size = 11;
    };
    settings = {
      background_opacity = "0.95";
      window_padding_width = 8;
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      cursor_blink_interval = 0;
      # TokyoNight color scheme
      background = "#1a1b26";
      foreground = "#c0caf5";
      selection_background = "#283457";
      selection_foreground = "#c0caf5";
      url_color = "#9ece6a";
      cursor = "#c0caf5";
      # black
      color0 = "#15161e";
      color8 = "#414868";
      # red
      color1 = "#f7768e";
      color9 = "#f7768e";
      # green
      color2 = "#9ece6a";
      color10 = "#9ece6a";
      # yellow
      color3 = "#e0af68";
      color11 = "#e0af68";
      # blue
      color4 = "#7aa2f7";
      color12 = "#7aa2f7";
      # magenta
      color5 = "#9d7cd8";
      color13 = "#9d7cd8";
      # cyan
      color6 = "#7dcfff";
      color14 = "#7dcfff";
      # white
      color7 = "#a9b1d6";
      color15 = "#c0caf5";
    };
  };
}
