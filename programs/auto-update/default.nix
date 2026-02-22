{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.byDb.autoUpdate;
  updateScript = pkgs.writeShellApplication {
    name = "bydb-update";

    runtimeInputs = with pkgs; [
      coreutils
      gnutar
      xz.bin
      gzip
      gitMinimal
      su
      iputils
    ];
    runtimeEnv = {
      GIT_SSH_COMMAND = "ssh -o StrictHostKeyChecking=accept-new";
    };

    text = ''
      if ! [ "$(id -u)" = 0 ]; then
        echo "This script must be run as root." >&2
        exit 1
      fi

      if [ "$#" = "0" ]; then
        REBUILD_OPERATION=boot
      elif [ "$#" = "1" ] && [ "$1" == "--now" ]; then
        REBUILD_OPERATION=switch
      else
        echo "Usage: bydb-update [--now]"
        echo "  --now: Apply the update immediately instead of on next reboot"
        exit 1
      fi

      while ! ping -c 1 github.com &> /dev/null; do
        if [ $SECONDS -gt 300 ]; then
          echo "No internet connection after 5 minutes, giving up."
          exit 1
        fi
        echo "No internet connection, retrying in 5 seconds..."
        sleep 5
      done

      cd '${cfg.flakePath}'
      OWNER=$(stat -c "%U" '.')

      DIRTY_FILES=$( (${lib.boolToString cfg.stashUnstash} && su "$OWNER" -c "git status --porcelain=v1" | grep -v 'flake.lock') || true)

      echo "Updating flake inputs..."
      SUM=$(md5sum flake.lock)
      set +e
      UPDATE_OUTPUT=$(su "$OWNER" -c "nix flake update --commit-lock-file" 2>&1)
      UPDATE_STATUS=$?
      set -e
      echo "$UPDATE_OUTPUT"

      if [ "$(echo "$UPDATE_OUTPUT" | grep "warning: could not update")" != "" ]; then
        UPDATE_STATUS=1
      fi

      if [ "$UPDATE_STATUS" = "0" ] && [ "$REBUILD_OPERATION" != "switch" ] && [ "$(md5sum flake.lock)" = "$SUM" ]; then
        echo "Inputs unchanged, no rebuild needed."
        exit
      fi

      set +e
      if [ "$UPDATE_STATUS" = "0" ] && (
        if [ "$DIRTY_FILES" != "" ]; then
          echo "Dirty repository, stashing changes..."
          su "$OWNER" -c "git stash"
        fi

        echo "Rebuilding..."
        git config --global --add safe.directory '${cfg.flakePath}'
        git config --global --add safe.directory '${cfg.flakePath}/.git'
        nixos-rebuild --flake '.' "$REBUILD_OPERATION"
      ); then
        ICON="update-low"
        TITLE="Auto-update succeeded"
        MESSAGE="System configuration flake inputs have been updated."
        if [ "$REBUILD_OPERATION" = "boot" ]; then
          MESSAGE="$MESSAGE\nChanges will be applied at the next boot."
        elif [ "$REBUILD_OPERATION" = "switch" ]; then
          MESSAGE="$MESSAGE\nChanges were applied successfully."
        fi
        STATUS=0
      else
        ICON="update-high"
        TITLE="Auto-update failed"
        MESSAGE="Failed to update system configuration.\nCheck: sudo systemctl status bydb-auto-update"
        STATUS=1
      fi

      if [ "$UPDATE_STATUS" = "0" ] && [ "$DIRTY_FILES" != "" ]; then
        echo "Un-stashing changes..."
        su "$OWNER" -c "git stash pop"
      fi

      su "$OWNER" -c "DISPLAY=':0' DBUS_SESSION_BUS_ADDRESS='unix:path=/run/user/$(stat -c "%u" '.')/bus' '${pkgs.lib.getExe' pkgs.libnotify "notify-send"}' \
        --app-name='NixOS auto-update' \
        --icon='$ICON' \
        '$TITLE' \
        '$MESSAGE'"

      exit "$STATUS"
    '';
  };
in
{
  options.byDb.autoUpdate = with lib; {
    enable = mkEnableOption "periodic automatic update of NixOS configuration";

    flakePath = mkOption {
      type = types.str;
      description = "Path to the flake containing the system configuration";
    };

    stashUnstash = mkOption {
      type = types.bool;
      description = "Whether to stash dirty changes before rebuilding and restore them afterward";
      default = true;
    };

    startAt = mkOption {
      type = types.str;
      description = "When to run the update. See systemd.time(7) for format.";
      default = "daily";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd = {
      services.bydb-auto-update = {
        serviceConfig.Type = "oneshot";
        description = "Periodic NixOS configuration update";

        inherit (cfg) startAt;

        after = [
          "graphical.target"
          "network-online.target"
        ];
        wants = [
          "graphical.target"
          "network-online.target"
        ];

        restartIfChanged = false;
        unitConfig.X-StopOnRemoval = false;

        environment =
          config.nix.envVars
          // {
            inherit (config.environment.sessionVariables) NIX_PATH;
            HOME = "/root";
          }
          // config.networking.proxy.envVars;

        path = [
          config.nix.package.out
          config.programs.ssh.package
          config.system.build.nixos-rebuild
        ];

        script = "${updateScript}/bin/bydb-update";
      };
      timers.bydb-auto-update.timerConfig.Persistent = true;
    };

    environment.systemPackages = [ updateScript ];
  };
}
