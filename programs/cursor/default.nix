{
  config,
  lib,
  pkgs-unstable,
  pkgs,
  ...
}:
let
  modifier = config.xsession.windowManager.i3.config.modifier;
  homeDir = config.home.homeDirectory;
  nixConfigsRepo = "${homeDir}/${config.by-db.nixConfigsRepo}";
  rofi = config.rofi.defaultCmd;
  open-local = "${pkgs.writeScriptBin "open-local" ''
    selection=$(
      list-crate-dirs ${homeDir}/code Cargo.toml 2>/dev/null | \
      ${rofi} -theme-str 'window {width: 20%;}'
    )
    if [[ $selection = "code" ]]; then
      cursor $HOME/code
    elif [[ $selection ]]; then
      cursor $HOME/code/$selection
    fi
  ''}/bin/open-local";
  open-cerberus = "${pkgs.writeScriptBin "open-cerberus" ''
    selection=$(
      ssh cerberus "./list-crate-dirs ./Stockly/Main stockly-package.json" 2>/dev/null | \
      ${rofi} -theme-str 'window {width: 30%;}'
    )
    if [[ $selection = "Main" ]]; then
      cursor --folder-uri=vscode-remote://ssh-remote+cerberus/home/romain/Stockly/Main
    elif [[ $selection ]]; then
      cursor --folder-uri=vscode-remote://ssh-remote+cerberus/home/romain/Stockly/Main/$selection
    fi
  ''}/bin/open-cerberus";
  open-salon = "${pkgs.writeScriptBin "open-salon" ''
    selection=$(
      ssh salon "list-crate-dirs /home/romain/code Cargo.toml" 2>/dev/null | \
      ${rofi} -theme-str 'window {width: 20%;}'
    )
    if [[ $selection = "code" ]]; then
      cursor --folder-uri=vscode-remote://ssh-remote+salon/home/romain/code
    elif [[ $selection ]]; then
      cursor --folder-uri=vscode-remote://ssh-remote+salon/home/romain/code/$selection
    fi
  ''}/bin/open-salon";
in
{
  home = {
    packages = [
      pkgs-unstable.code-cursor
    ];
    file = {
      ".vscode/extensions/stockly.monokai-stockly-1.0.0".source = ./MonokaiStockly;
    };
  };

  by-db-pkgs.list-crate-dirs.enable = true;

  xsession.windowManager.i3.config = {
    assigns = {
      "$ws3" = [ { class = "Cursor"; } ];
    };
    keybindings = lib.mkOptionDefault {
      "${modifier}+Control+v" = "workspace $ws3; exec ${open-local}";
      "${modifier}+Shift+v" = "workspace $ws3; exec ${open-cerberus}";
      "${modifier}+Mod1+v" = "workspace $ws3; exec ${open-salon}";
      "${modifier}+Control+n" = "workspace $ws3; exec cursor ${nixConfigsRepo}";
      "${modifier}+Mod1+n" =
        "workspace $ws3; exec cursor --folder-uri=vscode-remote://ssh-remote+salon/home/romain/nix-configs";
    };
  };
}
