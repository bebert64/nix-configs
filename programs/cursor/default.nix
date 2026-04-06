{
  config,
  lib,
  pkgsUnstable,
  pkgs,
  ...
}:
let
  inherit (config.xsession.windowManager.i3.config) modifier;
  inherit (config.byDb) paths;
  homeDir = config.home.homeDirectory;
  inherit (paths) nixPrograms;
  rofi = config.rofi.defaultCmd;
  # Lists worktree display names: "Main" stays "Main", "Main_foo" becomes "foo"
  listWorktreeNames = pkgs.writeScript "list-worktree-names" ''
    #!/usr/bin/env bash
    cd "$1" && {
      for d in Main Main_*; do
        [ -d "$d" ] && echo "$d"
      done
    } | LC_ALL=C sort -fu | sed 's/^Main_//'
  '';
  listSubdirs = pkgs.writeScript "list-subdirs" ''
    #!/usr/bin/env bash
    # $1 = full path to worktree; lists "Root" plus any subdir containing .vscode
    echo "Root"
    cd "$1" && \
      fd -t d -0 \
        --exec-batch bash -c '
          for d in "$@"; do
            [[ -d "$d/.vscode" ]] && printf "%s\n" "$d"
          done
          exit 0
        ' _ | sed 's|^./||' | LC_ALL=C sort -f
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
  mkOpenScript =
    {
      scriptName,
      host ? null,
      basePath,
      rofiWidth ? "20%",
      nixConfigsPath ? null,
    }:
    let
      isRemote = host != null;
      isNix = nixConfigsPath != null;
      fetchNames =
        if isRemote
        then "timeout 5 ssh -o ConnectTimeout=5 ${host} bash -s -- ${basePath} < ${listWorktreeNames} 2>/dev/null"
        else "${listWorktreeNames} ${basePath} 2>/dev/null";
      fetchSubdirs =
        if isRemote
        then "ssh ${host} bash -s -- ${basePath}/$worktree < ${listSubdirs} 2>/dev/null"
        else "${listSubdirs} ${basePath}/$worktree 2>/dev/null";
      nameMenuInput =
        if isNix
        then ''(echo "nix-configs only"; echo "$names") | ''
        else ''echo "$names" | '';
      nameCheck =
        if isNix
        then ''
          if [[ "$name" == "nix-configs only" ]]; then
            ${if isRemote then "cursor --folder-uri=vscode-remote://ssh-remote+${host}${nixConfigsPath}" else "cursor ${nixConfigsPath}"}
          elif [[ -n "$name" ]]; then''
        else ''
          if [[ -n "$name" ]]; then'';
      openTarget =
        if isNix then
          if isRemote
          then ''
            workspace_file=$(ssh ${host} bash -s -- ${nixConfigsPath} "$path" < ${writeNixWorkspace})
            cursor --file-uri="vscode-remote://ssh-remote+${host}$workspace_file"''
          else ''
            workspace_file=$(${writeNixWorkspace} ${nixConfigsPath} "$path")
            cursor "$workspace_file"''
        else if isRemote
          then "cursor --folder-uri=vscode-remote://ssh-remote+${host}/$path"
          else ''cursor "$path"'';
    in
    "${pkgs.writeScriptBin scriptName ''
      names=$(${fetchNames})
      ${lib.optionalString isRemote ''
      if [[ $? -ne 0 ]]; then
        ${pkgs.libnotify}/bin/notify-send -u critical "${scriptName}" "${host} is unreachable"
        exit 1
      fi
      ''}name=$(${nameMenuInput}${rofi} -theme-str 'window {width: ${rofiWidth};}')
      ${nameCheck}
        [[ "$name" == "Main" ]] && worktree="Main" || worktree="Main_$name"
        subdirs=$(${fetchSubdirs})
        subdir=$(echo "$subdirs" | ${rofi} -theme-str 'window {width: ${rofiWidth};}')
        if [[ -z "$subdir" ]]; then exit 0; fi
        path="${basePath}/$worktree"
        [[ "$subdir" != "Root" ]] && path="$path/$subdir"
        ${openTarget}
      fi
    ''}/bin/${scriptName}";
  openLocal    = mkOpenScript { scriptName = "open-local";     basePath = paths.codeRoot; };
  openOrthos   = mkOpenScript { scriptName = "open-orthos";    host = "orthos"; basePath = "/home/romain/Stockly"; rofiWidth = "30%"; };
  openSalon    = mkOpenScript { scriptName = "open-salon";     host = "salon";  basePath = "/home/romain/code"; };
  openNixLocal = mkOpenScript { scriptName = "open-nix-local"; basePath = paths.codeRoot;          nixConfigsPath = paths.nixConfigs; };
  openNixSalon = mkOpenScript { scriptName = "open-nix-salon"; host = "salon";  basePath = "/home/romain/code"; nixConfigsPath = "/home/romain/code/nix-configs"; };
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
      symlinkCursor = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ln -sfT ${nixPrograms}/cursor/commands ${homeDir}/.cursor/commands
        ln -sfT ${nixPrograms}/cursor/rules/global ${homeDir}/.cursor/rules
        ln -sfT ${nixPrograms}/cursor/skills ${homeDir}/.cursor/skills
      '';
    };
  };

  xsession.windowManager.i3.config = {
    assigns = {
      "$ws3" = [ { class = "Cursor"; } ];
    };
    keybindings = lib.mkOptionDefault {
      "${modifier}+Control+v" = "workspace $ws3; exec ${openLocal}";
      "${modifier}+Shift+v" = "workspace $ws3; exec ${openOrthos}";
      "${modifier}+Mod1+v" = "workspace $ws3; exec ${openSalon}";
      "${modifier}+Control+n" = "workspace $ws3; exec ${openNixLocal}";
      "${modifier}+Shift+n" =
        "workspace $ws3; exec cursor --folder-uri=vscode-remote://ssh-remote+orthos/home/romain/nix-configs";
      "${modifier}+Mod1+n" = "workspace $ws3; exec ${openNixSalon}";
    };
  };
}
