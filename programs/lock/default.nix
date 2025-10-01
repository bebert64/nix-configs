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
  homeDir = config.home.homeDirectory;
  nixConfigsRepo = "${homeDir}/${config.by-db.nixConfigsRepo}";
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
          wk1=$(i3-msg -t get_workspaces | ${jq}/bin/jq -r '.[] | select(.visible==true).name' | sed -n '1p')
          wk2=$(i3-msg -t get_workspaces | ${jq}/bin/jq -r '.[] | select(.visible==true).name' | sed -n '2p')

          sed -i -E 's/^([[:space:]]*"fullscreenLaunch":[[:space:]]*)false(,?)/\1true\2/' ${nixConfigsRepo}/programs/mpc-qt/settings.json
          sed -i -E 's/^([[:space:]]*"afterPlaybackDefault":[[:space:]]*)2(,?)/\11\2/' ${nixConfigsRepo}/programs/mpc-qt/settings.json
          { read -r wallpaper1; read -r wallpaper2; } < <(wallpapers-manager lock-wallpapers fifty-fifty)

          i3-msg "workspace \"19:󰸉\";exec mpc-qt $wallpaper1 --name lock1"
          if [[ $wk2 ]]; then
            i3-msg "workspace \"20:󰸉\";exec mpc-qt $wallpaper2 --name lock2";
          fi;

          ${cmd}

          # Lock
          alock -bg none -cursor blank -i none

          # Restore original config
          i3-msg workspace "$wk1"
          if [[ $wk2 ]]; then
            i3-msg workspace "$wk2";
          fi;

          ps aux | grep mpc-qt | grep allpapers | grep -v psg | grep -v grep | awk '{print $2}' | xargs -r kill

          sleep 0.5
          sed -i -E 's/^([[:space:]]*"fullscreenLaunch":[[:space:]]*)true(,?)/\1false\2/' ${nixConfigsRepo}/programs/mpc-qt/settings.json
          sed -i -E 's/^([[:space:]]*"afterPlaybackDefault":[[:space:]]*)1(,?)/\12\2/' ${nixConfigsRepo}/programs/mpc-qt/settings.json

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
          xidlehook --timer ${toString (cfg.minutes-from-lock-to-sleep * 60)} 'systemctl suspend' ' ' &
        '')
        (lockScript "lock-sleep" "sleep 2 && systemctl suspend")
        (lockScript "lock-dont-sleep" ''
          ${killXidlehook}
          xidlehook --timer ${toString (cfg.minutes-from-lock-to-sleep * 60)} 'xset dpms force off' ' ' &
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
            "--release ${modifier}+o" = "exec lock, mode default";
            "--release d" = "exec lock-dont-sleep, mode default";
            Escape = "mode default";
            Return = "mode default";
          };
        };
      };
    };

}
