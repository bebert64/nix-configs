# Terminal
{
  pkgs,
  lib,
  config,
  ...
}:
let
  modifier = config.byDb.modifier;
  rofi = config.rofi.defaultCmd;
  rofiScreenshots = "${pkgs.writeScriptBin "rofi-screenshots" ''
    selection="$(echo -en \
    'Gui to clipboard
    Gui to file
    Fullscreen to clipboard
    Fullscreen to file' \
    | ${rofi} )"

    case "$selection" in
      "Gui to clipboard")
        flameshot gui -r | xclip -selection clipboard -t image/png ;;
      "Gui to file")
        flameshot gui -p "${screenshotsDir}" ;;
      "Fullscreen to clipboard")
        flameshot full r | xclip -selection clipboard -t image/png ;;
      "Fullscreen to file")
        flameshot full -p "${screenshotsDir}" ;;
    esac
  ''}/bin/rofi-screenshots";
  homeDir = config.home.homeDirectory;
  screenshotsDir = "${homeDir}/screenshots";
in
{
  home = {
    packages = with pkgs; [
      flameshot
    ];

    activation = {
      createScreenshotsDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p ${homeDir}/screenshots/
      '';
    };
  };

  wayland.windowManager.sway.config = {
    keybindings = lib.mkOptionDefault {
      "${modifier}+Print" = "exec ${rofiScreenshots}";
    };
  };
}
