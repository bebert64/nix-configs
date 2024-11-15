{ pkgs, ... }:
{
  home = {
    packages = with pkgs.libsForQt5; [
      qt5ct
      qtstyleplugins
    ];
    file = {
      ".config/qt5ct/qt5ct.conf".source = ./qt5ct.conf;
    };
    sessionVariables = {
      QT_QPA_PLATFORMTHEME = "qt5ct";
    };
  };
}
