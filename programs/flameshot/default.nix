# Terminal
{
  pkgs,
  lib,
  config,
  ...
}:
let
  modifier = config.xsession.windowManager.i3.config.modifier;
  rofiScreenshots = "${pkgs.writeScriptBin "rofi-screenshots" ''
    selection="$(echo -en \
    'Gui to clipboard
    Gui to file
    Fullscreen to clipboard
    Fullscreen to file' \
    | ${config.rofi.defaultCmd} )"

    case "$selection" in
      "Gui to clipboard")
        flameshot gui -r | xclip -selection clipboard -t image/png ;;
      "Gui to file")
        flameshot gui -p "${screenshotsDirectory}" ;;
      "Fullscreen to clipboard")
        flameshot full r | xclip -selection clipboard -t image/png ;;
      "Fullscreen to file")
        flameshot full -p "${screenshotsDirectory}" ;;
    esac
  ''}/bin/rofi-screenshots";
  homeDirectory = config.home.homeDirectory;
  screenshotsDirectory = "${homeDirectory}/screenshots";
in
{
  home = {
    packages = with pkgs; [
      flameshot
    ];

    activation = {
      createScreenshotsDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p ${homeDirectory}/screenshots/
      '';
    };
  };

  xsession.windowManager.i3.config = {
    keybindings = lib.mkOptionDefault {
      "${modifier}+Print" = "exec ${rofiScreenshots}";
    };
  };
}
