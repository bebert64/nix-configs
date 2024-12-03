{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      gtk-engine-murrine
      libsForQt5.qt5ct
      libsForQt5.qtstyleplugins
    ];

    file = {
      ".config/qt5ct/qt5ct.conf".source = ./qt5ct.conf;
      # ".themes".source = "${pkgs.palenight-theme}/share/themes";
    };

    pointerCursor = {
      x11.enable = true;
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 20;
    };

    sessionVariables = {
      QT_QPA_PLATFORMTHEME = "qt5ct";
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
