{ pkgs, playerctl-script, ... }:
{
  enable = true;

  package = pkgs.polybar.override {
    i3Support = true;
    pulseSupport = true;
  };

  settings =
    let
      colors = import ./colors.nix;
    in
    import ./bars.nix colors
    // import ./glyphs.nix colors
    // import ./modules.nix { inherit colors playerctl-script; };

  script = ''
    while IFS= read -r line;
    do
     for BAR in $line;
     do
       polybar $BAR 2>/home/romain/polybar_log &
     done
    done < $HOME/.config/polybar/bars '';
}
