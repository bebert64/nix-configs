{ config, pkgs, ... }:
let
  inherit (config.lib.formats.rasi) mkLiteral;
  inherit (pkgs) writeScriptBin;
in
{
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

    home.packages = [
      (writeScriptBin "choose-radios" ''
        psg() {
          ps aux | grep $1 | grep -v grep
        }

        play_radio() {
          IS_STRAWBERRY_LAUNCHED=$(psg strawberry)

          if [[ ! $IS_STRAWBERRY_LAUNCHED ]]; then
              strawberry &
          fi

          while [[ ! $IS_STRAWBERRY_LAUNCHED ]]; do
              IS_STRAWBERRY_LAUNCHED=$(psg strawberry)
              sleep 1
          done

          strawberry --play-playlist Radios &
          strawberry --play-track $1 &
        }

        MENU="$(echo -en \
        'FIP\0icon\x1f${./icons/fip.png}
        Jazz Radio\0icon\x1f${./icons/jazz-radio.jpg}
        Radio Nova\0icon\x1f${./icons/nova.jpg}
        Oui FM\0icon\x1f${./icons/Oui-FM.png}
        Classic FM\0icon\x1f${./icons/classic-FM.png}
        Chillhop Radio\0icon\x1f${./icons/chillhop.jpg}' \
        | rofi -dmenu -show-icons -i -p 'Radio')"

        case "$MENU" in
          FIP) play_radio 0 ;;
          "Jazz Radio") play_radio 1 ;;
          "Radio Nova") play_radio 2 ;;
          "Oui FM") play_radio 3 ;;
          "Classic FM") play_radio 4 ;;
          "Chillhop Radio") i3-msg "workspace 10:; exec firefox -new-window https://www.youtube.com/watch\?v\=5yx6BWlEVcY" ;;
        esac
      '')
    ];

    xsession.windowManager.i3.config.menu = "\"rofi -modi drun#window#run -show drun -show-icons\"";
  };
}
