{
  pkgs,
  config,
  lib,
  ...
}:
let
  modifier = config.xsession.windowManager.i3.config.modifier;
  homeDir = config.home.homeDirectory;
  nixConfigsRepo = "${homeDir}/${config.by-db.nixConfigsRepo}";
  open-local = "${pkgs.writeScriptBin "open-local" ''
    selection=$(
      list-crate-dirs ${homeDir}/code Cargo.toml $HOME 2>/dev/null | \
      sort -u | \
      rofi -sort -sorting-method fzf -disable-history -dmenu -show-icons -no-custom -p ""
    )
    code $HOME/$selection
  ''}/bin/open-local";
  open-remote = "${pkgs.writeScriptBin "open-remote" ''
    selection=$(
      ssh cerberus "list-crate-dirs ./Stockly/Main stockly-package.json" 2>/dev/null | \
      sort -u | \
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
    by-db-packages.list-crate-dirs.enable = true;
  };

  xsession.windowManager.i3.config = {
    assigns = {
      "$ws3" = [ { class = "Code"; } ];
    };
    keybindings = lib.mkOptionDefault {
      "${modifier}+Control+v" = "workspace $ws3; exec ${open-local}";
      "${modifier}+Shift+v" = "workspace $ws3; exec ${open-remote}";
      "${modifier}+Control+n" = "workspace $ws3; exec code ${nixConfigsRepo}";
    };
  };
}
