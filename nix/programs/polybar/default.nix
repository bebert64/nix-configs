{ pkgs, ... }:
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
    import ./bars.nix colors // import ./glyphs.nix colors // import ./modules.nix colors;

  script = ''
    while IFS= read -r line;
    do
     for BAR in $line;
     do
       polybar $BAR &
     done
    done < $HOME/.config/polybar/bars '';
}
