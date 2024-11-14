{ pkgs, ... }: {
  home = {
    # imagemagick and scrot are used for image manipulation
    # to create the blur patches behind the conky widgets
    packages = with pkgs; [
      conky
      imagemagick
      scrot
    ];
    # file = {
    #   ".conky".source = ./conky;
    # };
  };
  xsession.windowManager.i3.config.startup = [
    {
      command = "conky -c ${./qclocktwo} -d";
      notification = false;
    }
  ];
}
