{
  config,
  lib,
  pkgs,
  ...
}:
let
  symlinkPath = config.sops.defaultSymlinkPath;

  notionTodoSync = pkgs.writeShellApplication {
    name = "notion-todo-sync";
    runtimeInputs = with pkgs; [
      curl
      jq
    ];
    text = builtins.readFile ./sync.sh;
  };
in
{
  options.byDb.notionTodoSync.enable = lib.mkEnableOption "Notion TODO board sync from shared databases";

  config = lib.mkIf config.byDb.notionTodoSync.enable {
    home.packages = [ notionTodoSync ];

    programs.zsh.initContent = ''
      alias sync-todo="systemctl --user start notion-todo-sync"
    '';

    systemd.user.services.notion-todo-sync = {
      Unit.Description = "Sync Notion shared DB tickets to personal TODO board";
      Service = {
        Type = "oneshot";
        ExecStart = "${notionTodoSync}/bin/notion-todo-sync";
        Environment = [
          "MCP_TOKEN_FILE=${symlinkPath}/stockly/mcp/notion-token"
          "PERSONAL_TOKEN_FILE=${symlinkPath}/notion/personal-token"
        ];
      };
    };

    systemd.user.timers.notion-todo-sync = {
      Unit.Description = "Run Notion TODO sync on schedule";
      Install.WantedBy = [ "timers.target" ];
      Timer = {
        OnCalendar = [
          "*-*-* 08:30:00"
          "*-*-* 09..17:00/15:00"
          "*-*-* 18:30:00"
          "*-*-* 19:00:00"
        ];
        Persistent = true;
      };
    };
  };
}
