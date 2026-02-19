{ config, ... }:
{
  services.polybar.settings =
    let
      byDbHomeManager = config.by-db;
      colors = byDbHomeManager.polybar.colors;
    in
    {
      "glyphs" = {
        type = "custom/text";
        format = {
          font = 3;
        };
      };
      "glyphs-left" = {
        "inherit" = "glyphs";
        format = {
          text = "";
        };
      };
      "glyphs-right" = {
        "inherit" = "glyphs";
        format = {
          text = "";
        };
      };
      "module/left1" = {
        "inherit" = "glyphs-left";
        format = {
          foreground = "${colors.shade1}";
          background = "${colors.shade6}";
        };
      };

      "module/left2" = {
        "inherit" = "glyphs-left";
        format = {
          foreground = "${colors.shade6}";
          background = "${colors.background}";
        };
      };

      "module/right1" = {
        "inherit" = "glyphs-right";
        format = {
          foreground = "${colors.shade1}";
          background = "${colors.shade2}";
        };
      };

      "module/right2" = {
        "inherit" = "glyphs-right";
        format = {
          foreground = "${colors.shade2}";
          background = "${colors.shade3}";
        };
      };

      "module/right3" = {
        "inherit" = "glyphs-right";
        format = {
          foreground = "${colors.shade3}";
          background = "${colors.shade4}";
        };
      };

      "module/right4" = {
        "inherit" = "glyphs-right";
        format = {
          foreground = "${colors.shade4}";
          background = "${colors.shade5}";
        };
      };

      "module/right5" = {
        "inherit" = "glyphs-right";
        format = {
          foreground = "${colors.shade5}";
          background = "${colors.shade6}";
        };
      };

      "module/right6" = {
        "inherit" = "glyphs-right";
        format = {
          foreground = "${colors.shade6}";
          background = "${colors.shade7}";
        };
      };

      "module/right7" = {
        "inherit" = "glyphs-right";
        format = {
          foreground = "${colors.shade7}";
          background = "${colors.shade8}";
        };
      };

      "module/right7-background" = {
        "inherit" = "glyphs-right";
        format = {
          foreground = "${colors.shade7}";
          background = "${colors.background}";
        };
      };

      "module/right8" = {
        "inherit" = "glyphs-right";
        format = {
          foreground = "${colors.shade8}";
          background = "${colors.background}";
        };
      };
    };
}
