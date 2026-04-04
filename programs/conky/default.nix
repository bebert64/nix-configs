{ pkgs, ... }:
{
  home = {
    # imagemagick and grim are used for image manipulation
    # to create the blur patches behind the conky widgets
    packages = with pkgs; [
      conky
      imagemagick
      grim
      # qt6.qttools # needed to extract artUrl from strawberry and display it with conky
    ];
  };
  wayland.windowManager.sway.config.startup = [
    {
      command = "conky -c ${./qclocktwo} -d";
    }
  ];
}
