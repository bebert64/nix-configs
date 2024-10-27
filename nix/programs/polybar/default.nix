{ pkgs, script-playerctl, ... }:
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
    // import ./modules.nix { inherit colors script-playerctl; };

  script = ''
    for BAR in $(${pkgs.coreutils}/bin/cat $HOME/.config/polybar/bars);
    do
      polybar $BAR 2>/home/romain/polybar_log &
    done'';
}
