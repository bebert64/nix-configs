{ pkgs, ... }:
{
  config = {
    home.packages =
      with pkgs; [
        (nerdfonts.override {
          fonts = [
            "FiraCode"
            "Iosevka"
          ];
        })
      ];
    fonts.fontconfig.enable = true;
  };
}
