{ config, lib, ... }:
let
  inherit (lib) mkOption types;
  inherit (types) str;
  inherit (config.lib.formats.rasi) mkLiteral;
in
{
  options.rofi = {
    defaultCmd = mkOption {
      type = str;
      default = "rofi -i -dmenu -no-custom -p \"\"";
    };
  };

  config = {
    programs.rofi = {
      enable = true;
      font = "Iosevka Nerd Font 10";
      extraConfig = {
        show-icons = true;
        icon-theme = "Papirus";
        display-drun = "";
        drun-display-format = "{name}";
        disable-history = false;
        fullscreen = false;
        hide-scrollbar = true;
        sidebar-mode = false;
      };

      theme =
        let
          colors = {
            ac = "#00000000";
            al = "#00000000";
            bg = "#1F1F1FFF";
            bg1 = "#283593FF";
            bg2 = "#303F9FFF";
            bg3 = "#3949ABFF";
            bg4 = "#3F51B5FF";
            fg = "#FFFFFFFF";
          };
        in
        {
          window = {
            transparency = "real";
            background-color = mkLiteral "${colors.bg}";
            text-color = mkLiteral "${colors.fg}";
            border = mkLiteral "0px";
            border-color = mkLiteral "${colors.ac}";
            border-radius = mkLiteral "12px";
            width = mkLiteral "350px";
            location = mkLiteral "center";
            x-offset = 0;
            y-offset = 0;
          };

          prompt = {
            enabled = true;
            padding = mkLiteral "10px 15px 10px 15px";
            background-color = mkLiteral "${colors.bg1}";
            text-color = mkLiteral "#FFFFFF";
          };

          textbox-prompt-colon = {
            padding = mkLiteral "10px 15px 10px 15px";
            background-color = mkLiteral "${colors.bg1}";
            text-color = mkLiteral "#FFFFFF";
            expand = false;
            str = "";
          };

          entry = {
            background-color = mkLiteral "${colors.bg2}";
            text-color = mkLiteral "#FFFFFF";
            placeholder-color = mkLiteral "#FFFFFF";
            expand = true;
            horizontal-align = 0;
            placeholder = "Search...";
            padding = mkLiteral "10px";
            border-radius = mkLiteral "0px 12px 12px 0px";
            blink = true;
          };

          inputbar = {
            children = mkLiteral "[ prompt, entry ]";
            background-color = mkLiteral "${colors.bg2}";
            text-color = mkLiteral "#FFFFFF";
            expand = false;
            border = mkLiteral "0px";
            border-radius = mkLiteral "12px";
            border-color = mkLiteral "${colors.ac}";
            spacing = mkLiteral "0px";
          };

          listview = {
            background-color = mkLiteral "${colors.al}";
            padding = mkLiteral "10px 10px 10px 10px";
            columns = 1;
            lines = 10;
            fixed-height = false;
            spacing = mkLiteral "5px";
            cycle = true;
            dynamic = true;
            layout = mkLiteral "vertical";
          };

          mainbox = {
            background-color = mkLiteral "${colors.al}";
            border = mkLiteral "0px";
            border-radius = mkLiteral "0px";
            border-color = mkLiteral "${colors.bg4}";
            children = mkLiteral " [ inputbar, listview ]";
            spacing = mkLiteral "0px";
            padding = mkLiteral "0px";
          };

          element = {
            background-color = mkLiteral "${colors.al}";
            text-color = mkLiteral "${colors.fg}";
            orientation = mkLiteral "horizontal";
            border-radius = mkLiteral "0px";
            padding = mkLiteral "6px";
          };

          element-icon = {
            background-color = mkLiteral "transparent";
            text-color = mkLiteral "inherit";
            size = mkLiteral "24px";
            border = mkLiteral "0px";
          };

          element-text = {
            background-color = mkLiteral "transparent";
            text-color = mkLiteral "inherit";
            expand = true;
            horizontal-align = 0;
            vertical-align = mkLiteral "0.5";
            margin = mkLiteral "0px 2.5px 0px 2.5px";
          };

          "element selected" = {
            background-color = mkLiteral " ${colors.bg3}";
            text-color = mkLiteral "${colors.bg}";
            border = mkLiteral "0px 0px 0px 0px";
            border-radius = mkLiteral "12px";
            border-color = mkLiteral "${colors.bg1}";
          };
        };
    };

    xsession.windowManager.i3.config.menu = "\"rofi -show drun -show-icons\"";
  };
}
