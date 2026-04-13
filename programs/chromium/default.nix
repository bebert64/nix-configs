{
  config,
  lib,
  pkgs,
  ...
}:
let
  modifier = config.byDb.modifier;

  # Wrapper that patches Chromium's Preferences before launch so it
  # auto-restores the previous session after a crash, instead of showing
  # the "Restore" prompt.  A per-profile counter stops patching after
  # maxCrashes consecutive crash-starts to avoid an infinite crash loop.
  maxCrashes = 3;
  chromium-session-restore = pkgs.writeShellScriptBin "chromium-session-restore" ''
    CHROMIUM_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}/chromium"
    PROFILE="Default"

    for arg in "$@"; do
      case "$arg" in
        --profile-directory=*) PROFILE="''${arg#--profile-directory=}" ;;
      esac
    done

    PREFS="$CHROMIUM_DIR/$PROFILE/Preferences"
    COUNTER_FILE="$CHROMIUM_DIR/.crash-restore-count-$PROFILE"

    if [ -f "$PREFS" ]; then
      exit_type=$(${lib.getExe pkgs.jq} -r '.profile.exit_type // "Normal"' "$PREFS")

      if [ "$exit_type" = "Crashed" ]; then
        count=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
        count=$((count + 1))

        if [ "$count" -le ${toString maxCrashes} ]; then
          tmp=$(mktemp)
          ${lib.getExe pkgs.jq} \
            '.profile.exit_type = "Normal" | .profile.exited_cleanly = true' \
            "$PREFS" > "$tmp" && mv "$tmp" "$PREFS"
          echo "$count" > "$COUNTER_FILE"
        fi
      else
        rm -f "$COUNTER_FILE"
      fi
    fi

    exec chromium "$@"
  '';
in
{
  programs.chromium = {
    enable = true;
    commandLineArgs = [
      "--force-dark-mode"
      "--enable-features=WebUIDarkMode"
    ];
  };

  home.packages = [ chromium-session-restore ];

  wayland.windowManager.sway.config = {
    keybindings = lib.mkOptionDefault {
      "${modifier}+Control+c" = "workspace $ws2; exec chromium-session-restore --profile-directory=Default";
    };
    assigns = {
      "$ws2" = [ { class = "chromium-browser"; } ];
    };
  };
}
