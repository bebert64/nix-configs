{ pkgs, ... }:
{
  config = {
    home.packages = [ pkgs.thunderbird ];

    xsession.windowManager.i3.config = {
      assigns = {
        "$ws5" = [ { class = "thunderbird"; } ];
      };
    };
  };
}
