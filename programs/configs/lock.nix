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

  config =
    let
      lockScript =
        scriptName: cmd:
        writeScriptBin scriptName ''
          # Prepare screen
          pkill polybar || echo "polybar already killed"
          wk1=$(i3-msg -t get_workspaces | ${jq}/bin/jq '.[] | select(.visible==true).name' | head -1)
          wk2=$(i3-msg -t get_workspaces | ${jq}/bin/jq '.[] | select(.visible==true).name' | tail -1)
          i3-msg workspace 11:󰸉
          i3-msg workspace 12:󰸉

          ${cmd}

          # Lock
          alock -bg none -cursor blank

          # Restore original config
          i3-msg workspace "$wk1"
          i3-msg workspace "$wk2"
          systemctl --user restart polybar
          pkill xidlehook || echo "xidlehook already killed"
          xidlehook --timer ${toString (cfg.minutes-before-lock * 60)} 'lock-wait-sleep' ' ' &
        '';
      killXidlehook = ''pkill xidlehook || echo "xidlehook already killed"'';
      lockMode = "Lock: l[o]ck, lock [d]on't sleep, [n]ever sleep";
    in
    {
      home.packages = [
        alock
        xidlehook
        (lockScript "lock" ''
          ${killXidlehook}
          xidlehook --timer ${toString (cfg.minutes-from-lock-to-sleep * 60)} 'xset dpms force off' ' ' &
        '')
        (lockScript "lock-wait-sleep" ''
          ${killXidlehook}
          xidlehook --timer ${toString (cfg.minutes-from-lock-to-sleep * 60)} 'systemctl suspend' ' ' &
        '')
        (lockScript "lock-sleep" "systemctl suspend")
        (writeScriptBin "wait-lock-2-hours" ''
          ${killXidlehook}
          xidlehook --timer ${toString (2 * 60 * 60)} 'lock-wait-sleep' ' ' &
        '')
      ];

      xsession.windowManager.i3.config = {
        startup = [
          {
            command = "xidlehook --timer ${
              toString (cfg.minutes-before-lock or 3 * 60)
            } 'lock-wait-sleep' ' ' &";
            notification = false;
          }
        ];
        keybindings = lib.mkOptionDefault {
          "--release ${modifier}+o" = "mode \"${lockMode}\"";
        };
        modes = {
          ${cfg.i3.exitMode} = {
            "--release s" = "exec lock-sleep, mode default";
          };

          ${lockMode} = {
            "--release o" = "exec lock-wait-sleep, mode default";
            "--release d" = "exec lock, mode default";
            "--release n" = "exec wait-lock-2-hours, mode default";
            Escape = "mode default";
            Return = "mode default";
          };
        };
      };
    };

}
