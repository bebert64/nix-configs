{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (pkgs)
    jq
    libnotify
    swaylock-effects
    writeShellScriptBin
    ;
  homeManagerBydbConfig = config.byDb;
  modifier = config.byDb.modifier;
  lockMode = "Lock: [l]ock, [d]on't sleep";
  primary = homeManagerBydbConfig.screens.primary;
  secondary = homeManagerBydbConfig.screens.secondary;
  hasSecondary = secondary != "";

  swaymsg = "${pkgs.sway}/bin/swaymsg";
  jqBin = "${jq}/bin/jq";

  # Transparent background + indicator so the wallpapers on workspaces 19/20
  # show through the lock surface.
  swaylockCmd = ''
    ${swaylock-effects}/bin/swaylock \
      --fade-in 0.2 \
      --clock \
      --timestr "%H:%M" \
      --datestr "%e %b %Y" \
      --color 00000000 \
      --inside-color 1a1b26bb \
      --ring-color 7aa2f7 \
      --key-hl-color c0caf5 \
      --separator-color 00000000 \
      --text-color c0caf5 \
      --indicator-radius 100 \
      --indicator-thickness 7'';

  # Shared pre/post logic: stop waybar, switch both outputs to the wallpaper
  # workspaces (19/20), run swaylock, then restore the previously-visible
  # workspaces and restart waybar. Workspaces 19/20 are assumed empty (same
  # assumption as `mod+i` / showWallpapers).
  lockWithWallpapers = pkgs.writeShellScript "lock-with-wallpapers" ''
    set -u

    restore() {
      ${swaymsg} focus output ${primary} || true
      ${swaymsg} workspace "$wk_primary" || true
      ${lib.optionalString hasSecondary ''
        ${swaymsg} focus output ${secondary} || true
        ${swaymsg} workspace "$wk_secondary" || true
        ${swaymsg} focus output ${primary} || true
      ''}
      systemctl --user start waybar || true
    }
    trap restore EXIT

    wk_primary=$(${swaymsg} -t get_workspaces | ${jqBin} -r '.[] | select(.output == "${primary}" and .visible) | .name')
    ${lib.optionalString hasSecondary ''
      wk_secondary=$(${swaymsg} -t get_workspaces | ${jqBin} -r '.[] | select(.output == "${secondary}" and .visible) | .name')
    ''}

    systemctl --user stop waybar || true

    ${swaymsg} focus output ${primary}
    ${swaymsg} workspace number 19
    ${lib.optionalString hasSecondary ''
      ${swaymsg} focus output ${secondary}
      ${swaymsg} workspace number 20
      ${swaymsg} focus output ${primary}
    ''}

    ${swaylockCmd}
  '';

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
    exec ${lockWithWallpapers}
  '';

  lockSleepScript = writeShellScriptBin "lock-sleep" ''
    (sleep 1 && systemctl suspend) &
    exec ${lockWithWallpapers}
  '';

  lockDontSleepScript = writeShellScriptBin "lock-dont-sleep" ''
    exec ${lockWithWallpapers}
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
        "${modifier}+o" = "mode \"${lockMode}\"";
      };
      modes = {
        ${homeManagerBydbConfig.sway.exitMode} = {
          "--release s" = "exec ${lockSleepScript}/bin/lock-sleep, mode default";
        };
        ${lockMode} = {
          "${modifier}+o" = "exec ${lockScript}/bin/lock, mode default";
          "d" = "exec ${lockDontSleepScript}/bin/lock-dont-sleep, mode default";
          Escape = "mode default";
          Return = "mode default";
        };
      };
    };
  };
}
