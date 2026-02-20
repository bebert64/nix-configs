{
  config,
  lib,
  pkgsUnstable,
  pkgs,
  ...
}:
let
  modifier = config.xsession.windowManager.i3.config.modifier;
  paths = config.byDb.paths;
  homeDir = config.home.homeDirectory;
  nixPrograms = paths.nixPrograms;
  rofi = config.rofi.defaultCmd;
  openLocal = "${pkgs.writeScriptBin "open-local" ''
    selection=$(
      list-crate-dirs ${paths.mainCodingRepo} Cargo.toml 2>/dev/null | \
      ${rofi} -theme-str 'window {width: 20%;}'
    )
    if [[ $selection = "code" ]]; then
      cursor ${paths.mainCodingRepo}
    elif [[ $selection ]]; then
      cursor ${paths.mainCodingRepo}/$selection
    fi
  ''}/bin/open-local";
  openCerberus = "${pkgs.writeScriptBin "open-cerberus" ''
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
  openSalon = "${pkgs.writeScriptBin "open-salon" ''
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
      pkgsUnstable.code-cursor
    ];
    file = {
      ".cursor/extensions/stockly.monokai-stockly-1.0.0".source = ./MonokaiStockly;
    };
    activation = {
      symlinkCursorCommands = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ln -sfT ${nixPrograms}/cursor/commands ${homeDir}/.cursor/commands
      '';
    };
  };

  byDbPkgs.list-crate-dirs.enable = true;

  xsession.windowManager.i3.config = {
    assigns = {
      "$ws3" = [ { class = "Cursor"; } ];
    };
    keybindings = lib.mkOptionDefault {
      "${modifier}+Control+v" = "workspace $ws3; exec ${openLocal}";
      "${modifier}+Shift+v" = "workspace $ws3; exec ${openCerberus}";
      "${modifier}+Mod1+v" = "workspace $ws3; exec ${openSalon}";
      "${modifier}+Control+n" = "workspace $ws3; exec cursor ${paths.nixConfigs}";
      "${modifier}+Mod1+n" =
        "workspace $ws3; exec cursor --folder-uri=vscode-remote://ssh-remote+salon/home/romain/nix-configs";
    };
  };
}
