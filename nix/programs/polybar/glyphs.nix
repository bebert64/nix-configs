colors:
let
  glyph = {
    left = "";
    right = "";
  };
in
{
  "module/left1" = {
    type = "custom/text";
    content = {
      padding-right = 2;
      background = "${colors.shade6}";
      foreground = "${colors.shade1}";
      text = "${glyph.left}";
      font = 3;
    };
  };

  "module/left2" = {
    type = "custom/text";
    content = {
      background = "${colors.background}";
      foreground = "${colors.shade6}";
      text = "${glyph.left}";
      font = 3;
    };
  };

  "module/right1" = {
    type = "custom/text";
    content = {
      background = "${colors.shade2}";
      foreground = "${colors.shade1}";
      text = "${glyph.right}";
      font = 3;
    };
  };

  "module/right2" = {
    type = "custom/text";
    content = {
      background = "${colors.shade4}";
      foreground = "${colors.shade2}";
      text = "${glyph.right}";
      font = 3;
    };
  };

  "module/right4" = {
    type = "custom/text";
    content = {
      background = "${colors.shade5}";
      foreground = "${colors.shade4}";
      text = "${glyph.right}";
      font = 3;
    };
  };

  "module/right5" = {
    type = "custom/text";
    content = {
      background = "${colors.shade6}";
      foreground = "${colors.shade5}";
      text = "${glyph.right}";
      font = 3;
    };
  };

  "module/right6" = {
    type = "custom/text";
    content = {
      background = "${colors.shade7}";
      foreground = "${colors.shade6}";
      text = "${glyph.right}";
      font = 3;
    };
  };

  "module/right7" = {
    type = "custom/text";
    content = {
      background = "${colors.background}";
      foreground = "${colors.shade7}";
      text = "${glyph.right}";
      font = 3;
    };
  };
}
