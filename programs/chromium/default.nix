{
  config,
  lib,
  pkgs,
  ...
}:
let
  modifier = config.byDb.modifier;
  ws = config.byDb.ws;

  # Wrapper that patches Chromium's Preferences before launch so it
  # auto-restores the previous session after a crash, instead of showing
  # the "Restore" prompt.  To break a crash loop, launch `chromium` directly.
  chromium-session-restore = pkgs.writeShellScriptBin "chromium-session-restore" ''
    CHROMIUM_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}/chromium"
    PROFILE="Default"

    for arg in "$@"; do
      case "$arg" in
        --profile-directory=*) PROFILE="''${arg#--profile-directory=}" ;;
      esac
    done

    PREFS="$CHROMIUM_DIR/$PROFILE/Preferences"

    if [ -f "$PREFS" ]; then
      exit_type=$(${lib.getExe pkgs.jq} -r '.profile.exit_type // "Normal"' "$PREFS")

      if [ "$exit_type" = "Crashed" ]; then
        tmp=$(mktemp)
        ${lib.getExe pkgs.jq} \
          '.profile.exit_type = "Normal" | .profile.exited_cleanly = true' \
          "$PREFS" > "$tmp" && mv "$tmp" "$PREFS"
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
      "${modifier}+Control+c" = "workspace \"${ws."2"}\"; exec chromium-session-restore --profile-directory=Default";
    };
    assigns = {
      "\"${ws."2"}\"" = [ { class = "chromium-browser"; } ];
    };
  };
}
