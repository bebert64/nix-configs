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
      (echo "code"
       cd ${paths.mainCodingRepo} && fd -t d -0 \
        --exec-batch bash -c '
          for d in "$@"; do
            [[ -d "$d/.vscode" ]] && printf "%s\n" "$d"
          done
          exit 0
        ' _ | sed 's|^./||' | sort -fu) 2>/dev/null | \
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
      ssh cerberus "
        cd ~/Stockly && {
          for d in Main Main_*; do
            [ -d \"\$d\" ] && echo \"\$d\"
          done
          fd -t d -0 \
            --exec-batch bash -c '
              for d in \"\$@\"; do
                [[ -d \"\$d/.vscode\" ]] && printf \"%s\n\" \"\$d\"
              done
              exit 0
            ' _ | sed 's|^./||'
        } | grep -E '^Main(_[^/]*)?' \
          | LC_ALL=C sort -fu
      " 2>/dev/null | \
      ${rofi} -theme-str 'window {width: 30%;}'
    )
    if [[ $selection ]]; then
      cursor --folder-uri=vscode-remote://ssh-remote+cerberus/home/romain/Stockly/$selection
    fi
  ''}/bin/open-cerberus";
  openSalon = "${pkgs.writeScriptBin "open-salon" ''
    selection=$(
      ssh salon "(
        echo code
        cd /home/romain/code && fd -t d -0 \
          --exec-batch bash -c '
            for d in \"\$@\"; do
              [[ -d \"\$d/.vscode\" ]] && printf \"%s\n\" \"\$d\"
            done
            exit 0
          ' _ | sed 's|^./||' | sort -fu
      )" 2>/dev/null | \
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
      pkgs.fd
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
