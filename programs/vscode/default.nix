{
  pkgs,
  config,
  lib,
  ...
}:
let
  modifier = config.xsession.windowManager.i3.config.modifier;
in
{
  home = {
    packages = with pkgs; [
      vscode
      polkit # polkit is the utility used by vscode to save as sudo
    ];
    file = {
      ".vscode/extensions/stockly.monokai-stockly-1.0.0".source = ./MonokaiStockly;
    };
  };

  xsession.windowManager.i3.config = {
    assigns = {
      "$ws3" = [ { class = "Code"; } ];
    };
    keybindings = lib.mkOptionDefault { "${modifier}+Control+v" = "workspace $ws3; exec code"; };
  };
}
