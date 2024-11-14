{ pkgs, ... }: {
  home = {
    # imagemagick and scrot are used for image manipulation
    # to create the blur patches behind the conky widgets
    packages = with pkgs; [
      conky
      imagemagick
      scrot
      # qt6.qttools # needed to extract artUrl from strawberry and display it with conky
    ];
  };
  xsession.windowManager.i3.config.startup = [
    {
      command = "conky -c ${./qclocktwo} -d";
      notification = false;
    }
  ];
}
