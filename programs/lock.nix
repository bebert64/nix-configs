# Alock is a locker allowing transparent background
{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
  inherit (types) int;
  inherit (pkgs)
    alock
    jq
    xidlehook
    writeScriptBin
    ;
  cfg = config.by-db;
  modifier = config.xsession.windowManager.i3.config.modifier;
in
{
  options.by-db = {
    minutes-before-lock = mkOption {
      type = int;
      default = 3;
      description = "Minutes before the computer locks itself";
    };
    minutes-from-lock-to-sleep = mkOption {
      type = int;
      default = 7;
      description = "Minutes from the moment the computer locks itself to the moment it starts sleeping";
    };
  };

  config = {
    home.packages = [
      alock
      xidlehook
      (writeScriptBin "lock-conky" ''
        SLEEP=false
        while getopts "s" opt; do
          case $opt in
            s) SLEEP=true;;
            \?) echo "Invalid option. To sleep, use -s";;
          esac
        done

        # Prepare screen
        pkill polybar || echo "polybar already killed"
        wk1=$(i3-msg -t get_workspaces | ${jq}/bin/jq '.[] | select(.visible==true).name' | head -1)
        wk2=$(i3-msg -t get_workspaces | ${jq}/bin/jq '.[] | select(.visible==true).name' | tail -1)
        i3-msg workspace 11:󰸉
        i3-msg workspace 12:󰸉

        # Sleep or prepare to sleep
        if [[ $SLEEP == true ]]; then
          systemctl suspend
        else
          pkill xidlehook || echo "xidlehook already killed"
          xidlehook --timer ${toString (cfg.minutes-from-lock-to-sleep * 60)} 'systemctl suspend' ' ' &
        fi

        # Lock
        alock -bg none -cursor blank

        # Revert to original config
        i3-msg workspace "$wk1"
        i3-msg workspace "$wk2"
        systemctl --user restart polybar
        pkill xidlehook || echo "xidlehook already killed"
        xidlehook --timer ${toString (cfg.minutes-before-lock * 60)} 'lock-conky' ' ' &
      '')
    ];

    xsession.windowManager.i3.config = {
      startup = [
        {
          command = "xidlehook --timer ${toString (cfg.minutes-before-lock or 3 * 60)} 'lock-conky' ' ' &";
          notification = false;
        }
      ];
      keybindings = {
        # Lock the screen.
        "--release ${modifier}+o" = "exec lock-conky";
      };
    };
  };

}
