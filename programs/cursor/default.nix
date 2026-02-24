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
  listCodeProjects = pkgs.writeScript "list-code-projects" ''
    #!/usr/bin/env bash
    cd "$1" && {
      for d in Main Main_*; do
        [ -d "$d" ] && echo "$d"
      done
      fd -t d -0 \
        --exec-batch bash -c '
          for d in "$@"; do
            [[ -d "$d/.vscode" ]] && printf "%s\n" "$d"
          done
          exit 0
        ' _ | sed 's|^./||'
    } | grep -E '^Main(_[^/]*)?' \
      | LC_ALL=C sort -fu
  '';
  writeNixWorkspace = pkgs.writeScript "write-nix-workspace" ''
    #!/usr/bin/env bash
    nix_configs_path="$1"
    code_worktree_path="$2"
    workspace_dir="$HOME/.cursor/workspaces"
    mkdir -p "$workspace_dir"
    worktree_name=$(basename "$code_worktree_path")
    workspace_file="$workspace_dir/nix-with-$worktree_name.code-workspace"
    cat > "$workspace_file" << EOF
    {
      "folders": [
        {"path": "$nix_configs_path"},
        {"path": "$code_worktree_path"}
      ]
    }
    EOF
    echo "$workspace_file"
  '';
  openLocal = "${pkgs.writeScriptBin "open-local" ''
    selection=$(
      ${listCodeProjects} ${paths.codeRoot} 2>/dev/null | \
      ${rofi} -theme-str 'window {width: 20%;}'
    )
    if [[ $selection ]]; then
      cursor ${paths.codeRoot}/$selection
    fi
  ''}/bin/open-local";
  openCerberus = "${pkgs.writeScriptBin "open-cerberus" ''
    selection=$(
      ssh cerberus bash -s -- ~/Stockly < ${listCodeProjects} 2>/dev/null | \
      ${rofi} -theme-str 'window {width: 30%;}'
    )
    if [[ $selection ]]; then
      cursor --folder-uri=vscode-remote://ssh-remote+cerberus/home/romain/Stockly/$selection
    fi
  ''}/bin/open-cerberus";
  openSalon = "${pkgs.writeScriptBin "open-salon" ''
    selection=$(
      ssh salon bash -s -- /home/romain/code < ${listCodeProjects} 2>/dev/null | \
      ${rofi} -theme-str 'window {width: 20%;}'
    )
    if [[ $selection ]]; then
      cursor --folder-uri=vscode-remote://ssh-remote+salon/home/romain/code/$selection
    fi
  ''}/bin/open-salon";
  openNixLocal = "${pkgs.writeScriptBin "open-nix-local" ''
    selection=$(
      (echo "nix-configs only"
       ${listCodeProjects} ${paths.codeRoot} 2>/dev/null | grep -v /
      ) | ${rofi} -theme-str 'window {width: 20%;}'
    )
    if [[ "$selection" == "nix-configs only" ]]; then
      cursor ${paths.nixConfigs}
    elif [[ $selection ]]; then
      workspace_file=$(${writeNixWorkspace} ${paths.nixConfigs} ${paths.codeRoot}/$selection)
      cursor "$workspace_file"
    fi
  ''}/bin/open-nix-local";
  openNixSalon = "${pkgs.writeScriptBin "open-nix-salon" ''
    selection=$(
      (echo "nix-configs only"
       ssh salon bash -s -- /home/romain/code < ${listCodeProjects} 2>/dev/null | grep -v /
      ) | ${rofi} -theme-str 'window {width: 20%;}'
    )
    if [[ "$selection" == "nix-configs only" ]]; then
      cursor --folder-uri=vscode-remote://ssh-remote+salon/home/romain/code/nix-configs
    elif [[ $selection ]]; then
      workspace_file=$(ssh salon bash -s -- /home/romain/code/nix-configs /home/romain/code/$selection < ${writeNixWorkspace})
      cursor --file-uri="vscode-remote://ssh-remote+salon$workspace_file"
    fi
  ''}/bin/open-nix-salon";
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
      symlinkCursorRules = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ln -sfT ${nixPrograms}/cursor/rules ${homeDir}/.cursor/rules
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
      "${modifier}+Control+n" = "workspace $ws3; exec ${openNixLocal}";
      "${modifier}+Shift+n" = "workspace $ws3; exec cursor --folder-uri=vscode-remote://ssh-remote+cerberus/home/romain/nix-configs";
      "${modifier}+Mod1+n" = "workspace $ws3; exec ${openNixSalon}";
    };
  };
}
