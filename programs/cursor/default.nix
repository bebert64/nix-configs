{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}:
let
  inherit (config.byDb) modifier;
  inherit (config.byDb) ws;
  inherit (config.byDb) paths;
  homeDir = config.home.homeDirectory;
  inherit (paths) nixPrograms;
  rofi = config.rofi.defaultCmd;
  # Lists worktree display names: prefix stays as-is, prefix_foo becomes "foo"
  # $1 = base path, $2 = prefix (default: Main)
  listWorktreeNames = pkgs.writeScript "list-worktree-names" ''
    #!/usr/bin/env bash
    prefix="''${2:-Main}"
    cd "$1" && {
      for d in "$prefix" "''${prefix}_"*; do
        [ -d "$d" ] && echo "$d"
      done
    } | LC_ALL=C sort -fu | sed "s/^''${prefix}_//"
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
  mkOpenScript =
    {
      scriptName,
      host ? null,
      basePath,
      rofiWidth ? "20%",
      worktreePrefix ? "Main",
      skipSubdirs ? false,
    }:
    let
      isRemote = host != null;
      fetchNames =
        if isRemote then
          "timeout 5 ssh -o ConnectTimeout=5 ${host} bash -s -- ${basePath} ${worktreePrefix} < ${listWorktreeNames} 2>/dev/null"
        else
          "${listWorktreeNames} ${basePath} ${worktreePrefix} 2>/dev/null";
      fetchSubdirs =
        if isRemote then
          "ssh ${host} bash -s -- ${basePath}/$worktree < ${listSubdirs} 2>/dev/null"
        else
          "${listSubdirs} ${basePath}/$worktree 2>/dev/null";
      openTarget =
        if isRemote then
          "cursor --folder-uri=vscode-remote://ssh-remote+${host}/$path"
        else
          ''cursor "$path"'';
      subdirBlock = ''
        subdirs=$(${fetchSubdirs})
        subdir=$(echo "$subdirs" | ${rofi} -theme-str 'window {width: ${rofiWidth};}')
        if [[ -z "$subdir" ]]; then exit 0; fi
        path="${basePath}/$worktree"
        [[ "$subdir" != "Root" ]] && path="$path/$subdir"
      '';
      directBlock = ''
        path="${basePath}/$worktree"
      '';
    in
    "${pkgs.writeScriptBin scriptName ''
      names=$(${fetchNames})
      ${lib.optionalString isRemote ''
        if [[ $? -ne 0 ]]; then
          ${pkgs.libnotify}/bin/notify-send -u critical "${scriptName}" "${host} is unreachable"
          exit 1
        fi
      ''}name=$(echo "$names" | ${rofi} -theme-str 'window {width: ${rofiWidth};}')
      if [[ -n "$name" ]]; then
        [[ "$name" == "${worktreePrefix}" ]] && worktree="${worktreePrefix}" || worktree="${worktreePrefix}_$name"
        ${if skipSubdirs then directBlock else subdirBlock}
        ${openTarget}
      fi
    ''}/bin/${scriptName}";
  openLocal = mkOpenScript {
    scriptName = "open-local";
    basePath = paths.codeRoot;
  };
  openOrthos = mkOpenScript {
    scriptName = "open-orthos";
    host = "orthos";
    basePath = "/home/romain/Stockly";
    rofiWidth = "30%";
  };
  openSalon = mkOpenScript {
    scriptName = "open-salon";
    host = "salon";
    basePath = "/home/romain/code";
  };
  openNixLocal = mkOpenScript {
    scriptName = "open-nix-local";
    basePath = paths.codeRoot;
    worktreePrefix = "nix-configs";
    skipSubdirs = true;
  };
  openNixSalon = mkOpenScript {
    scriptName = "open-nix-salon";
    host = "salon";
    basePath = "/home/romain/code";
    worktreePrefix = "nix-configs";
    skipSubdirs = true;
  };
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

  wayland.windowManager.sway.config = {
    assigns = {
      "\"${ws."3"}\"" = [ { class = "Cursor"; } ];
    };
    keybindings = lib.mkOptionDefault {
      "${modifier}+Control+v" = "workspace \"${ws."3"}\"; exec ${openLocal}";
      "${modifier}+Shift+v" = "workspace \"${ws."3"}\"; exec ${openOrthos}";
      "${modifier}+Mod1+v" = "workspace \"${ws."3"}\"; exec ${openSalon}";
      "${modifier}+Control+n" = "workspace \"${ws."3"}\"; exec ${openNixLocal}";
      "${modifier}+Shift+n" =
        "workspace \"${ws."3"}\"; exec cursor --folder-uri=vscode-remote://ssh-remote+orthos/home/romain/nix-configs";
      "${modifier}+Mod1+n" = "workspace \"${ws."3"}\"; exec ${openNixSalon}";
    };
  };
}
