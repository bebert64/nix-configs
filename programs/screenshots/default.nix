# Screenshots: grim (capture) + slurp (region select) + swappy (annotate)
{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (config.byDb) modifier;
  rofi = config.rofi.defaultCmd;
  grimBin = lib.getExe pkgs.grim;
  slurpBin = lib.getExe pkgs.slurp;
  swappyBin = lib.getExe pkgs.swappy;
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
        ${grimBin} -g "$(${slurpBin})" - | ${swappyBin} -f - ;;
      "Region to clipboard")
        ${grimBin} -g "$(${slurpBin})" - | ${wlCopy} -t image/png ;;
      "Region to file")
        ${grimBin} -g "$(${slurpBin})" "${screenshotsDir}/$(date +%Y-%m-%d_%H-%M-%S).png" ;;
      "Fullscreen to clipboard")
        ${grimBin} - | ${wlCopy} -t image/png ;;
      "Fullscreen to file")
        ${grimBin} "${screenshotsDir}/$(date +%Y-%m-%d_%H-%M-%S).png" ;;
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
