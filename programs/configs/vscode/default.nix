{
  pkgs,
  config,
  lib,
  ...
}:
let
  modifier = config.xsession.windowManager.i3.config.modifier;
  open-local = "${pkgs.writeScriptBin "open-local" ''
    selection=$(${pkgs.fd}/bin/fd . --type dir --base-directory $HOME 2>/dev/null | \
      rofi -sort -sorting-method fzf -disable-history -dmenu -show-icons -no-custom -p ""
    )
    code $HOME/$selection
  ''}/bin/open-local";
  open-remote = "${pkgs.writeScriptBin "open-remote" ''
    selection=$(ssh cerberus "nix run \"nixpkgs#fd\" -- --base-directory ./Stockly/Main --type dir" 2>/dev/null | \
        rofi -sort -sorting-method fzf -disable-history -dmenu -show-icons -no-custom -p ""
      )
      code --folder-uri=vscode-remote://ssh-remote+cerberus/home/romain/Stockly/Main/$selection
  ''}/bin/open-remote";
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
    keybindings = lib.mkOptionDefault {
      "${modifier}+Control+v" = "workspace $ws3; exec ${open-local}";
      "${modifier}+Control+Shift+v" = "workspace $ws3; exec ${open-remote}";
    };
  };
}
