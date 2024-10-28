colors:
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
      background = "${colors.shade6}";
      foreground = "${colors.shade1}";
    };
  };

  "module/left2" = {
    "inherit" = "glyphs-left";
    format = {
      background = "${colors.background}";
      foreground = "${colors.shade6}";
    };
  };

  "module/right1" = {
    "inherit" = "glyphs-right";
    format = {
      background = "${colors.shade2}";
      foreground = "${colors.shade1}";
    };
  };

  "module/right2" = {
    "inherit" = "glyphs-right";
    format = {
      background = "${colors.shade4}";
      foreground = "${colors.shade2}";
    };
  };

  "module/right4" = {
    "inherit" = "glyphs-right";
    format = {
      background = "${colors.shade5}";
      foreground = "${colors.shade4}";
    };
  };

  "module/right5" = {
    "inherit" = "glyphs-right";
    format = {
      background = "${colors.shade6}";
      foreground = "${colors.shade5}";
    };
  };

  "module/right6" = {
    "inherit" = "glyphs-right";
    format = {
      background = "${colors.shade7}";
      foreground = "${colors.shade6}";
    };
  };

  "module/right7" = {
    "inherit" = "glyphs-right";
    format = {
      background = "${colors.background}";
      foreground = "${colors.shade7}";
    };
  };
}
