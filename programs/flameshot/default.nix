# Screenshots: grim (capture) + slurp (region select) + swappy (annotate)
{
  pkgs,
  lib,
  config,
  ...
}:
let
  modifier = config.byDb.modifier;
  rofi = config.rofi.defaultCmd;
  grim = lib.getExe pkgs.grim;
  slurp = lib.getExe pkgs.slurp;
  swappy = lib.getExe pkgs.swappy;
  wlCopy = "${pkgs.wl-clipboard}/bin/wl-copy";

  rofiScreenshots = "${pkgs.writeScriptBin "rofi-screenshots" ''
    selection="$(echo -en \
    'Region to editor
    Region to clipboard
    Region to file
    Fullscreen to clipboard
    Fullscreen to file' \
    | ${rofi} )"

    case "$selection" in
      "Region to editor")
        ${grim} -g "$(${slurp})" - | ${swappy} -f - ;;
      "Region to clipboard")
        ${grim} -g "$(${slurp})" - | ${wlCopy} -t image/png ;;
      "Region to file")
        ${grim} -g "$(${slurp})" "${screenshotsDir}/$(date +%Y-%m-%d_%H-%M-%S).png" ;;
      "Fullscreen to clipboard")
        ${grim} - | ${wlCopy} -t image/png ;;
      "Fullscreen to file")
        ${grim} "${screenshotsDir}/$(date +%Y-%m-%d_%H-%M-%S).png" ;;
    esac
  ''}/bin/rofi-screenshots";
  homeDir = config.home.homeDirectory;
  screenshotsDir = "${homeDir}/screenshots";
in
{
  home = {
    packages = with pkgs; [
      grim
      slurp
      swappy
      wl-clipboard
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
