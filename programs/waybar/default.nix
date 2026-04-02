{
  pkgs,
  lib,
  config,
  by-db,
  ...
}:
let
  playerctlDisplayTitle = pkgs.writeShellScript "playerctl-display-title" ''
    PATH=${lib.makeBinPath [
      by-db.packages.x86_64-linux.music-title
      pkgs.playerctl
    ]}
    title_display=$(music-title 2>/dev/null)
    status=$(playerctl --ignore-player=firefox,chromium status 2>/dev/null)
    if [[ $status == "Playing" ]]; then
      prefix="♪"
    else
      prefix="󰝛"
    fi
    echo "$prefix  $title_display"
  '';
  headphonesOrSpeakerIcon = pkgs.writeShellScript "headphones-or-speaker-icon" ''
    PATH=${lib.makeBinPath [
      pkgs.gnugrep
      pkgs.pulseaudio
    ]}
    IS_HEADPHONES_ON=$(${config.byDb.isHeadphonesOnCommand})
    if [[ $IS_HEADPHONES_ON ]]; then
      echo " "
    else
      echo "󰓃"
    fi
  '';
in
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = [
      {
        layer = "top";
        position = "top";
        height = 24;

        modules-left = [
          "sway/workspaces"
          "sway/mode"
        ];
        modules-center = [ "custom/player" ];
        modules-right = [
          "custom/headphones"
          "pulseaudio"
          "network"
          "memory"
          "cpu"
          "disk"
          "battery"
          "clock"
          "tray"
        ];

        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = false;
          format = "{name}";
          persistent-workspaces = { };
        };

        "sway/mode" = { };

        "custom/player" = {
          exec = "${playerctlDisplayTitle}";
          interval = 1;
          format = "{}";
          return-type = "";
        };

        "custom/headphones" = {
          exec = "${headphonesOrSpeakerIcon}";
          interval = 2;
          format = "{}";
        };

        pulseaudio = {
          format = "{icon}  {volume}%";
          format-muted = "  muted";
          format-icons = {
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "pavucontrol";
          scroll-step = 5;
        };

        network = {
          format-wifi = "  {signalStrength}%  {bandwidthDownBytes}  {bandwidthUpBytes}";
          format-ethernet = "  {bandwidthDownBytes}  {bandwidthUpBytes}";
          format-disconnected = "󱚼  disconnected";
          interval = 2;
          tooltip-format = "{ifname} {ipaddr}";
        };

        memory = {
          format = "  {percentage}%";
          interval = 2;
        };

        cpu = {
          format = "  {usage}%";
          interval = 2;
        };

        disk = {
          format = "  {free}";
          path = "/";
          interval = 30;
        };

        battery = {
          format = "{icon}  {capacity}%";
          format-charging = "󰢝  {capacity}%";
          format-full = "󰂅  {capacity}%";
          format-icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰂃"
          ];
          states = {
            warning = 20;
            critical = 10;
          };
        };

        clock = {
          format = "{:%H:%M}";
          format-alt = "{:%e %b %Y}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        tray = {
          spacing = 8;
          icon-size = 20;
        };
      }
    ];
    style = builtins.readFile ./style.css;
  };
}
