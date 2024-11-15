{
  pkgs,
  config,
  lib,
  ...
}:
let
  modifier = config.xsession.windowManager.i3.config.modifier;
in
{
  config = {
    home.packages = [ pkgs.thunderbird ];

    xsession.windowManager.i3.config = {
      assigns = {
        "$ws5" = [ { class = "thunderbird"; } ];
      };

      keybindings = lib.mkOptionDefault {
        "${modifier}+Control+t" = "workspace $ws5; exec thunderbird -P Regular";
      };
    };
  };
}
