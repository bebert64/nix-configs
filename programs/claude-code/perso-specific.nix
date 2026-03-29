{ config, lib, pkgs, ... }:
let
  homeDir = config.home.homeDirectory;
  nixPrograms = config.byDb.paths.nixPrograms;
  symlinkPath = config.sops.defaultSymlinkPath;
in
{
  home.activation.symlinkClaudePerso = lib.hm.dag.entryAfter [ "symlinkClaudeSettings" ] ''
    # Perso skills
    for skill in ${nixPrograms}/claude-code/skills/perso/*/; do
      ln -sfT "$skill" ${homeDir}/.claude/skills/$(basename "$skill")
    done

    # Perso MCP servers
    ASANA_TOKEN="$(cat ${symlinkPath}/mcp/asana-token)"
    MCP_CONFIG=$(${pkgs.jq}/bin/jq -n \
      --arg asana_token "$ASANA_TOKEN" \
      '{mcpServers: {
        asana: {
          command: "npx",
          args: ["-y", "@roychri/mcp-server-asana"],
          env: {ASANA_ACCESS_TOKEN: $asana_token}
        }
      }}')
    if [ -f ${homeDir}/.claude.json ]; then
      ${pkgs.jq}/bin/jq -s '.[0] * .[1]' ${homeDir}/.claude.json - <<< "$MCP_CONFIG" > ${homeDir}/.claude.json.tmp
      mv ${homeDir}/.claude.json.tmp ${homeDir}/.claude.json
    else
      echo "$MCP_CONFIG" > ${homeDir}/.claude.json
    fi
  '';
}
