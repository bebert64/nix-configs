{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (pkgs)
    libnotify
    sway
    swaylock-effects
    writeShellScriptBin
    ;
  homeManagerBydbConfig = config.byDb;
  inherit (config.byDb) modifier;
  lockMode = "Lock: l[o]ck, [d]on't sleep";

  # Picks wallpapers via `wallpapers-manager lock-wallpapers` (which prints
  # `OUTPUT<TAB>PATH` lines, one per monitor, splitting a dual-screen wallpaper
  # into tiles when the two monitors share a resolution) and hands the paths
  # to swaylock via per-output `--image OUTPUT:PATH` flags. Falls back to a
  # solid background if the picker fails for any reason (empty pool, missing
  # binary, swaymsg error) so that locking never gets blocked.
  lockWithWallpapers = pkgs.writeShellScript "lock-with-wallpapers" ''
    set -u
    # swayidle (systemd --user) runs with a minimal PATH; make sure the
    # wallpapers-manager binary and its runtime deps (swaymsg, magick) are
    # findable.
    export PATH="$HOME/.nix-profile/bin:/run/current-system/sw/bin:$PATH"

    image_args=()
    if picks=$(wallpapers-manager lock-wallpapers 2>/dev/null); then
      while IFS=$'\t' read -r output path; do
        if [ -n "''${output:-}" ] && [ -n "''${path:-}" ]; then
          image_args+=(--image "$output:$path")
        fi
      done <<< "$picks"
    fi

    exec ${swaylock-effects}/bin/swaylock \
      ''${image_args[@]:+"''${image_args[@]}"} \
      "$@" \
      --fade-in 0.2 \
      --clock \
      --timestr "%H:%M" \
      --datestr "%e %b %Y" \
      --inside-color 1a1b26bb \
      --ring-color 7aa2f7 \
      --key-hl-color c0caf5 \
      --separator-color 00000000 \
      --text-color c0caf5 \
      --indicator-radius 100 \
      --indicator-thickness 7
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
    exec ${pkgs.systemd}/bin/systemctl suspend
  '';

  lockScript = writeShellScriptBin "lock" ''
    exec ${lockWithWallpapers} "$@"
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
        {
          event = "after-resume";
          command = "${sway}/bin/swaymsg output '*' dpms on";
        }
      ];
      timeouts = [
        {
          timeout = (homeManagerBydbConfig.minutesBeforeLock - 1) * 60;
          command = "${preLockNotify}/bin/pre-lock-notify";
        }
        {
          timeout = homeManagerBydbConfig.minutesBeforeLock * 60;
          command = "${lockScript}/bin/lock --daemonize";
        }
        {
          timeout =
            (homeManagerBydbConfig.minutesBeforeLock + homeManagerBydbConfig.minutesFromLockToSleep - 1) * 60;
          command = "${sway}/bin/swaymsg output '*' dpms off";
          resumeCommand = "${sway}/bin/swaymsg output '*' dpms on";
        }
        {
          timeout =
            (homeManagerBydbConfig.minutesBeforeLock + homeManagerBydbConfig.minutesFromLockToSleep) * 60;
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
