{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      gtk-engine-murrine
      kdePackages.qt6gtk2 # Used by qt6 app to load gtk theme
      libsForQt5.qt5ct # Used by caffeine to load gtk theme
      libsForQt5.qtstyleplugins # Used by qt5 app to load gtk theme
    ];

    pointerCursor = {
      x11.enable = true;
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 20;
    };

    sessionVariables = {
      QT_QPA_PLATFORMTHEME = "gtk2";
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Tokyonight-Dark";
      package = pkgs.tokyonight-gtk-theme;
    };
  };
}
