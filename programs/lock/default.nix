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
    minutes-before-lock = lib.mkOption {
      type = lib.types.int;
      default = 3;
      description = "Minutes before the computer locks itself";
    };
    minutes-from-lock-to-sleep = lib.mkOption {
      type = lib.types.int;
      default = 7;
      description = "Minutes from the moment the computer locks itself to the moment it starts sleeping";
    };
  };

  config =
    let
      # Auto-sleep: wait for incoming SSH connections to disconnect (retry every 2 min), then suspend.
      # Use /proc/net/tcp to avoid ss (which can be aliased to systemctl status). Port 22 = 0x0016 hex.
      suspendIfNoIncomingSsh = writeScriptBin "suspend-if-no-incoming-ssh" ''
        #!${pkgs.runtimeShell}
        set -e
        retry_interval=120
        has_incoming_ssh() {
          [ -n "$(awk 'FNR>1 && $4=="01" && $2~/:0016$/' /proc/net/tcp /proc/net/tcp6 2>/dev/null)" ]
        }
        while has_incoming_ssh; do
          sleep "$retry_interval"
        done
        exec systemctl suspend
      '';

      lockScript =
        scriptName: cmd:
        writeScriptBin scriptName ''
          # Prepare screen
          pkill polybar || echo "polybar already killed"
          wk1=$(i3-msg -t get_workspaces | ${jq}/bin/jq '.[] | select(.visible==true).name' | head -1)
          wk2=$(i3-msg -t get_workspaces | ${jq}/bin/jq '.[] | select(.visible==true).name' | tail -1)
          i3-msg workspace 19:󰸉
          i3-msg workspace 20:󰸉

          ${cmd}

          # Lock
          alock -bg none -cursor blank

          # Restore original config
          i3-msg workspace "$wk1"
          i3-msg workspace "$wk2"
          systemctl --user restart polybar

          pkill xidlehook || echo "xidlehook already killed"
          xidlehook --timer ${toString (cfg.minutes-before-lock * 60)} 'lock' ' ' &
        '';
      killXidlehook = ''pkill xidlehook || echo "xidlehook already killed"'';
      lockMode = "Lock: l[o]ck, [d]on't sleep";
    in
    {
      home.packages = [
        alock
        xidlehook
        (lockScript "lock" ''
          ${killXidlehook}
          xidlehook --timer ${
            toString (cfg.minutes-from-lock-to-sleep * 60)
          } 'suspend-if-no-incoming-ssh' ' ' &
        '')
        # Manual sleep (press s): always suspend immediately, ignore SSH
        (lockScript "lock-sleep" "sleep 1 && systemctl suspend")
        (lockScript "lock-dont-sleep" ''
          ${killXidlehook}
          xidlehook --timer ${toString (cfg.minutes-from-lock-to-sleep * 60)} 'xset dpms force off' ' ' &
        '')
        suspendIfNoIncomingSsh
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
            "--release ${modifier}+o" = "exec lock, mode default";
            "--release d" = "exec lock-dont-sleep, mode default";
            Escape = "mode default";
            Return = "mode default";
          };
        };
      };
    };

}
