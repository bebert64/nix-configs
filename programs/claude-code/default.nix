{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  nixPrograms = config.byDb.paths.nixPrograms;
  symlinkPath = config.sops.defaultSymlinkPath;
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
        ln -sf ${nixPrograms}/claude-code/settings.json ${homeDir}/.claude/settings.json

        # Global rules (Claude Code recurses into subdirectories)
        mkdir -p ${homeDir}/.claude/rules
        ln -sfT ${nixPrograms}/claude-code/rules/global ${homeDir}/.claude/rules/global

        # Global skills (each skill dir individually)
        mkdir -p ${homeDir}/.claude/skills
        shopt -s nullglob
        for skill in ${nixPrograms}/claude-code/skills/global/*/; do
          ln -sfT "$skill" "${homeDir}/.claude/skills/$(basename "$skill")"
        done
        shopt -u nullglob

        # Global commands (each .md file individually)
        mkdir -p ${homeDir}/.claude/commands
        shopt -s nullglob
        for cmd in ${nixPrograms}/claude-code/commands/global/*.md; do
          ln -sfT "$cmd" "${homeDir}/.claude/commands/$(basename "$cmd")"
        done
        shopt -u nullglob

        # Docs directory (individual items added by machine-specific nix files)
        mkdir -p ${homeDir}/.claude/docs

        # Sops secrets are only available after user login, not at boot.
        # Skip MCP config when they're absent — written on next interactive activation.
        if [ -f "${symlinkPath}/stockly/mcp/notion-token" ] && [ -f "${symlinkPath}/stockly/mcp/sentry-token" ]; then
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
        fi
      '';
    };
  };
}
