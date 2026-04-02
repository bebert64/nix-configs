{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (pkgs)
    libnotify
    swaylock-effects
    writeShellScriptBin
    ;
  homeManagerBydbConfig = config.byDb;
  modifier = config.byDb.modifier;
  lockMode = "Lock: [l]ock, [d]on't sleep";

  swaylockCmd = ''
    ${swaylock-effects}/bin/swaylock \
      --effect-blur 7x5 \
      --fade-in 0.2 \
      --clock \
      --timestr "%H:%M" \
      --datestr "%e %b %Y" \
      --color 1a1b26 \
      --inside-color 1a1b26bb \
      --ring-color 7aa2f7 \
      --key-hl-color c0caf5 \
      --separator-color 00000000 \
      --text-color c0caf5 \
      --text-date-color c0caf5 \
      --indicator-radius 100 \
      --indicator-thickness 7'';

  preLockNotify = writeShellScriptBin "pre-lock-notify" ''
    ${libnotify}/bin/notify-send -u normal "Locking soon" "Screen will lock in 1 minute"
  '';

  # Auto-sleep: wait for incoming SSH connections to disconnect (retry every 2 min), then suspend.
  # Use /proc/net/tcp to avoid ss (which can be aliased to systemctl status). Port 22 = 0x0016 hex.
  suspendIfNoIncomingSsh = writeShellScriptBin "suspend-if-no-incoming-ssh" ''
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

  lockScript = writeShellScriptBin "lock" ''
    exec ${swaylockCmd}
  '';

  lockSleepScript = writeShellScriptBin "lock-sleep" ''
    ${swaylockCmd} &
    sleep 1
    exec systemctl suspend
  '';

  lockDontSleepScript = writeShellScriptBin "lock-dont-sleep" ''
    exec ${swaylockCmd}
  '';
in
{
  options.byDb = {
    minutesBeforeLock = lib.mkOption {
      type = lib.types.int;
      default = 3;
      description = "Minutes before the computer locks itself";
    };
    minutesFromLockToSleep = lib.mkOption {
      type = lib.types.int;
      default = 7;
      description = "Minutes from the moment the computer locks itself to the moment it starts sleeping";
    };
    # Kept for compatibility with existing machine configs; swaylock uses PAM auth so this value is not used.
    lockPasswordHash = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Unused (swaylock uses PAM auth). Kept so existing machine configs don't break.";
    };
  };

  config = {
    home.packages = [
      swaylock-effects
      preLockNotify
      suspendIfNoIncomingSsh
      lockScript
      lockSleepScript
      lockDontSleepScript
    ];

    services.swayidle = {
      enable = true;
      events = [
        {
          event = "before-sleep";
          command = "${lockScript}/bin/lock";
        }
      ];
      timeouts = [
        {
          timeout = (homeManagerBydbConfig.minutesBeforeLock - 1) * 60;
          command = "${preLockNotify}/bin/pre-lock-notify";
        }
        {
          timeout = homeManagerBydbConfig.minutesBeforeLock * 60;
          command = "${lockScript}/bin/lock";
        }
        {
          timeout = (homeManagerBydbConfig.minutesBeforeLock + homeManagerBydbConfig.minutesFromLockToSleep) * 60;
          command = "${suspendIfNoIncomingSsh}/bin/suspend-if-no-incoming-ssh";
        }
      ];
    };

    wayland.windowManager.sway.config = {
      keybindings = lib.mkOptionDefault {
        "--release ${modifier}+o" = "mode \"${lockMode}\"";
      };
      modes = {
        ${homeManagerBydbConfig.sway.exitMode} = {
          "--release s" = "exec ${lockSleepScript}/bin/lock-sleep, mode default";
        };
        ${lockMode} = {
          "--release ${modifier}+o" = "exec ${lockScript}/bin/lock, mode default";
          "--release d" = "exec ${lockDontSleepScript}/bin/lock-dont-sleep, mode default";
          Escape = "mode default";
          Return = "mode default";
        };
      };
    };
  };
}
