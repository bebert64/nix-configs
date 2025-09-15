# Terminal
{
  pkgs,
  lib,
  config,
  ...
}:
let
  modifier = config.xsession.windowManager.i3.config.modifier;
  rofi = config.rofi.defaultCmd;
  rofi-screenshots = "${pkgs.writeScriptBin "rofi-screenshots" ''
    selection="$(
    echo -en \
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

  xsession.windowManager.i3.config = {
    keybindings = lib.mkOptionDefault {
      "${modifier}+Print" = "exec ${rofi-screenshots}";
    };
  };
}
