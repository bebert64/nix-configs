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
      list-crate-dirs ${homeDir}/code Cargo.toml 2>/dev/null | \
      sort -u | \
      rofi -sort -sorting-method fzf -i -disable-history -dmenu -show-icons -no-custom -p "" -theme-str 'window {width: 20%;}'
    )
    if [[ $selection = "code" ]]; then
      code $HOME/code
    elif [[ $selection ]]; then
      code $HOME/code/$selection
    fi
  ''}/bin/open-local";
  open-cerberus = "${pkgs.writeScriptBin "open-cerberus" ''
    selection=$(
      ssh cerberus "./list-crate-dirs ./Stockly/Main stockly-package.json" 2>/dev/null | \
      sort -u | \
      rofi -sort -sorting-method fzf -i -disable-history -dmenu -show-icons -no-custom -p "" -theme-str 'window {width: 30%;}'
    )
    if [[ $selection = "Main" ]]; then
      code --folder-uri=vscode-remote://ssh-remote+cerberus/home/romain/Stockly/Main
    elif [[ $selection ]]; then
      code --folder-uri=vscode-remote://ssh-remote+cerberus/home/romain/Stockly/Main/$selection
    fi
  ''}/bin/open-cerberus";
  open-salon = "${pkgs.writeScriptBin "open-salon" ''
    selection=$(
      ssh salon "list-crate-dirs ${homeDir}/code Cargo.toml 2>/dev/null | \
      sort -u | \
      rofi -sort -sorting-method fzf -i -disable-history -dmenu -show-icons -no-custom -p "" -theme-str 'window {width: 20%;}'
    )
    if [[ $selection = "code" ]]; then
      code --folder-uri=vscode-remote://ssh-remote+cerberus/home/romain/code
    elif [[ $selection ]]; then
      code --folder-uri=vscode-remote://ssh-remote+cerberus/home/romain/code/$selection
    fi
  ''}/bin/open-salon";
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

  by-db-pkgs.list-crate-dirs.enable = true;

  xsession.windowManager.i3.config = {
    assigns = {
      "$ws3" = [ { class = "Code"; } ];
    };
    keybindings = lib.mkOptionDefault {
      "${modifier}+Control+v" = "workspace $ws3; exec ${open-local}";
      "${modifier}+Shift+v" = "workspace $ws3; exec ${open-cerberus}";
      "${modifier}+Alt+v" = "workspace $ws3; exec ${open-salon}";
      "${modifier}+Control+n" = "workspace $ws3; exec code ${nixConfigsRepo}";
    };
  };
}
