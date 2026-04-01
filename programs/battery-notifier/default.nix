{
  config,
  lib,
  pkgs,
  ...
}:
let
  batteryNotifier = pkgs.writeScriptBin "battery-notifier" ''
    #!${pkgs.runtimeShell}
    last_notified=""
    while true; do
      capacity=$(cat /sys/class/power_supply/BAT1/capacity 2>/dev/null || echo 100)
      status=$(cat /sys/class/power_supply/BAT1/status 2>/dev/null || echo "Unknown")
      if [[ "$status" == "Discharging" ]]; then
        if (( capacity <= 10 )) && [[ "$last_notified" != "critical" ]]; then
          ${pkgs.libnotify}/bin/notify-send -u critical "Battery Critical" "''${capacity}% remaining"
          last_notified="critical"
        elif (( capacity <= 20 )) && [[ "$last_notified" == "" ]]; then
          ${pkgs.libnotify}/bin/notify-send -u normal "Battery Low" "''${capacity}% remaining"
          last_notified="low"
        elif (( capacity > 20 )); then
          last_notified=""
        fi
      else
        last_notified=""
      fi
      sleep 60
    done
  '';
in
{
  options.byDb.batteryNotifier.enable = lib.mkEnableOption "Battery level desktop notifications";

  config = lib.mkIf config.byDb.batteryNotifier.enable {
    home.packages = [ batteryNotifier ];

    systemd.user.services.battery-notifier = {
      Unit.Description = "Battery level notifier";
      Install.WantedBy = [ "default.target" ];
      Service = {
        ExecStart = "${batteryNotifier}/bin/battery-notifier";
        Restart = "always";
        RestartSec = "5s";
      };
    };
  };
}
