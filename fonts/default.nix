{ pkgs, ... }:
{
  config = {
    home.packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.iosevka
    ];
    fonts.fontconfig.enable = true;
  };
}
