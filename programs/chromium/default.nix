{
  config,
  lib,
  ...
}:
let
  modifier = config.byDb.modifier;
in
{
  programs.chromium = {
    enable = true;
    commandLineArgs = [
      "--force-dark-mode"
      "--enable-features=WebUIDarkMode"
    ];
  };

  wayland.windowManager.sway.config = {
    keybindings = lib.mkOptionDefault {
      "${modifier}+Control+c" = "workspace $ws2; exec chromium --profile-directory=Default";
    };
    assigns = {
      "$ws2" = [ { class = "chromium-browser"; } ];
    };
  };
}
