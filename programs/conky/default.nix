{ pkgs, ... }:
let
  # conky 1.22.2 has a bug where `textalpha` on the Wayland backend is
  # silently clobbered by load_fonts(), leaving text fully opaque. The patch
  # stores the configured alpha in a file-static and re-applies it after
  # load_fonts rebuilds the pango_fonts vector.
  conkyWithTextAlphaFix = pkgs.conky.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./textalpha-fix.patch ];
  });
in
{
  home = {
    # imagemagick and grim are used for image manipulation
    # to create the blur patches behind the conky widgets
    packages = with pkgs; [
      conkyWithTextAlphaFix
      imagemagick
      grim
      # qt6.qttools # needed to extract artUrl from strawberry and display it with conky
    ];
  };
  wayland.windowManager.sway.config.startup = [
    {
      command = "conky -c ${./qclocktwo} -d";
    }
  ];
}
