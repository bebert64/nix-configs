{ pkgs, lib, ... }:
{

  imports = [
    ./bars.nix
    ./glyphs.nix
    ./modules.nix
  ];

  options.by-db.polybar = {
    colors = lib.mkOption {
      type = lib.types.attrs;
      default = import ./colors.nix;
    };
  };

  config = {
    services.polybar = {
      enable = true;

      package = pkgs.polybar.override {
        i3Support = true;
        pulseSupport = true;
      };

      script = ''
        for BAR in $(${pkgs.coreutils}/bin/cat $HOME/.config/polybar/bars);
        do
          polybar $BAR &
        done'';
    };
  };
}
