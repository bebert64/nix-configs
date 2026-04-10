{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  inherit (config.byDb.paths) nixPrograms;
  symlinkPath = config.sops.defaultSymlinkPath;
  autoApprovePlansHook = pkgs.writeShellScript "claude-auto-approve-plans" ''
    ${pkgs.jq}/bin/jq -re '
      # Edit/Write use .tool_input.file_path, Bash uses .tool_input.command
      (.tool_input.file_path // .tool_input.command // "") as $target |
      if ($target | test("\\.claude/(plans|investigations)/")) then
        {
          hookSpecificOutput: {
            hookEventName: "PermissionRequest",
            decision: {
              behavior: "allow"
            }
          }
        }
      else empty end
    '
  '';
  mcpHealthCheckHook = pkgs.writeShellScript "claude-mcp-health-check" ''
    # Verify every configured MCP server is reachable before the session starts.
    # MCPs occasionally fail to spin up; the only known fix is exiting and
    # running `claude --continue`. We detect that here and abort loudly so the
    # agent never silently runs without its tools.
    output=$(${pkgsUnstable.claude-code}/bin/claude mcp list 2>&1)
    # Server lines look like `name: <cmd> - ✓ Connected` (or a failure suffix).
    if echo "$output" | ${pkgs.gnugrep}/bin/grep -E '^[A-Za-z0-9_.-]+:' | ${pkgs.gnugrep}/bin/grep -vq 'Connected'; then
      echo "[claude-mcp-health-check] One or more MCP servers failed to start." >&2
      echo "$output" >&2
      echo "" >&2
      echo "Fix: exit this session (Ctrl-D) and run \`claude --continue\`." >&2
      exit 2
    fi
  '';
  notifyHook = pkgs.writeShellScript "claude-notify" ''
    TITLE="Claude @ $(${pkgs.hostname}/bin/hostname)"
    BODY="Answer ready on $(${pkgs.git}/bin/git branch --show-current 2>/dev/null || echo 'no branch')"
    if [[ -n "$SSH_CLIENT" ]]; then
      ${pkgs.openssh}/bin/ssh -p 2222 -o ConnectTimeout=3 -o BatchMode=yes localhost "${pkgs.libnotify}/bin/notify-send '$TITLE' '$BODY'" || true
    else
      ${pkgs.libnotify}/bin/notify-send "$TITLE" "$BODY"
    fi
  '';
  settingsJson = pkgs.writeText "claude-settings.json" (
    builtins.toJSON (
      (builtins.fromJSON (builtins.readFile ./settings.json))
      // {
        hooks = {
          SessionStart = [
            {
              hooks = [
                {
                  type = "command";
                  command = "${mcpHealthCheckHook}";
                }
              ];
            }
          ];
          Stop = [
            {
              hooks = [
                {
                  type = "command";
                  command = "${notifyHook}";
                }
              ];
            }
          ];
          PermissionRequest = [
            {
              matcher = "Edit|Write|Bash";
              hooks = [
                {
                  type = "command";
                  command = "${autoApprovePlansHook}";
                }
              ];
            }
          ];
        };
      }
    )
  );
  claudeWithVoice = pkgs.writeShellScriptBin "claude" ''
    # PulseAudio forwarding for Claude Code voice mode on monsters
    if [ -S /tmp/pulse-forward ]; then
      export PULSE_SERVER=unix:/tmp/pulse-forward
    fi
    exec ${pkgsUnstable.claude-code}/bin/claude --dangerously-skip-permissions "$@"
  '';
in
{
  imports = [ ./terminal-title.nix ];

  home = {
    packages = [
      claudeWithVoice
      pkgs.sox
    ];
    activation = {
      symlinkClaudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" "setupSecrets" ] ''
        mkdir -p ${homeDir}/.claude
        ln -sf ${settingsJson} ${homeDir}/.claude/settings.json
        ln -sf ${nixPrograms}/claude-code/CLAUDE.md ${homeDir}/.claude/CLAUDE.md

        # Global rules (Claude Code recurses into subdirectories)
        mkdir -p ${homeDir}/.claude/rules
        ln -sfT ${nixPrograms}/claude-code/rules/global ${homeDir}/.claude/rules/global

        # Skills (whole dir — all skills available everywhere)
        ln -sfT ${nixPrograms}/claude-code/skills ${homeDir}/.claude/skills

        # Docs
        ln -sfT ${nixPrograms}/claude-code/docs ${homeDir}/.claude/docs

        NOTION_TOKEN="$(cat ${symlinkPath}/stockly/mcp/notion-token)"
        SENTRY_TOKEN="$(cat ${symlinkPath}/stockly/mcp/sentry-token)"
        MCP_CONFIG=$(${pkgs.jq}/bin/jq -n \
          --arg notion_token "$NOTION_TOKEN" \
          --arg sentry_token "$SENTRY_TOKEN" \
          '{mcpServers: {
            notion: {
              command: "npx",
              args: ["-y", "@notionhq/notion-mcp-server"],
              env: {NOTION_TOKEN: $notion_token}
            },
            sentry: {
              command: "npx",
              args: ["-y", "@sentry/mcp-server"],
              env: {SENTRY_ACCESS_TOKEN: $sentry_token, SENTRY_ORG_SLUG: "stockly"}
            }
          }}')
        if [ -f ${homeDir}/.claude.json ]; then
          ${pkgs.jq}/bin/jq -s '.[0] * .[1]' ${homeDir}/.claude.json - <<< "$MCP_CONFIG" > ${homeDir}/.claude.json.tmp
          mv ${homeDir}/.claude.json.tmp ${homeDir}/.claude.json
        else
          echo "$MCP_CONFIG" > ${homeDir}/.claude.json
        fi
      '';
    };
  };
}
