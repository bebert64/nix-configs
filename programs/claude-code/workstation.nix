{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.byDb) modifier ws paths;
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
  mkOpenScript =
    {
      scriptName,
      host ? null,
      basePath,
      rofiWidth ? "20%",
      worktreePrefix ? "Main",
    }:
    let
      isRemote = host != null;
      fetchNames =
        if isRemote then
          "timeout 5 ssh -o ConnectTimeout=5 ${host} bash -s -- ${basePath} ${worktreePrefix} < ${listWorktreeNames} 2>/dev/null"
        else
          "${listWorktreeNames} ${basePath} ${worktreePrefix} 2>/dev/null";
      openTarget =
        if isRemote then
          ''kitty --title "Claude (${host}: $name)" kitten ssh ${host} -t "cd '$path' && claude; exec \$SHELL"''
        else
          ''kitty --title "Claude ($name)" -e zsh -c "cd '$path' && claude"'';
    in
    "${pkgs.writeScriptBin scriptName ''
      names=$(${fetchNames})
      ${lib.optionalString isRemote ''
        if [[ $? -ne 0 ]]; then
          ${pkgs.libnotify}/bin/notify-send -u critical "${scriptName}" "${host} is unreachable"
          exit 1
        fi
      ''}
      if [[ $(echo "$names" | wc -l) -le 1 ]]; then
        name="$names"
      else
        name=$(echo "$names" | ${rofi} -theme-str 'window {width: ${rofiWidth};}')
      fi
      if [[ -n "$name" ]]; then
        [[ "$name" == "${worktreePrefix}" ]] && worktree="${worktreePrefix}" || worktree="${worktreePrefix}_$name"
        path="${basePath}/$worktree"
        ${openTarget}
      fi
    ''}/bin/${scriptName}";
  claudeLocal = mkOpenScript {
    scriptName = "claude-local";
    basePath = paths.codeRoot;
  };
  claudeOrthos = mkOpenScript {
    scriptName = "claude-orthos";
    host = "orthos";
    basePath = "/home/romain/Stockly";
    rofiWidth = "30%";
  };
  claudeSalon = mkOpenScript {
    scriptName = "claude-salon";
    host = "salon";
    basePath = "/home/romain/code";
  };
  claudeNixLocal = mkOpenScript {
    scriptName = "claude-nix-local";
    basePath = paths.codeRoot;
    worktreePrefix = "nix-configs";
  };
  claudeNixOrthos = mkOpenScript {
    scriptName = "claude-nix-orthos";
    host = "orthos";
    basePath = "/home/romain";
    worktreePrefix = "nix-configs";
  };
  claudeNixSalon = mkOpenScript {
    scriptName = "claude-nix-salon";
    host = "salon";
    basePath = "/home/romain/code";
    worktreePrefix = "nix-configs";
  };
in
{
  imports = [ ./common.nix ];

  wayland.windowManager.sway.config = {
    keybindings = lib.mkOptionDefault {
      "${modifier}+Control+a" = ''mode "claude"'';
    };
    modes = {
      claude = {
        "Control+c" = ''workspace "${ws."1"}"; exec ${claudeLocal}, mode default'';
        "Shift+c" = ''workspace "${ws."1"}"; exec ${claudeOrthos}, mode default'';
        "Mod1+c" = ''workspace "${ws."1"}"; exec ${claudeSalon}, mode default'';
        "Control+n" = ''workspace "${ws."1"}"; exec ${claudeNixLocal}, mode default'';
        "Shift+n" = ''workspace "${ws."1"}"; exec ${claudeNixOrthos}, mode default'';
        "Mod1+n" = ''workspace "${ws."1"}"; exec ${claudeNixSalon}, mode default'';
        "Escape" = "mode default";
        "Return" = "mode default";
      };
    };
  };
}
