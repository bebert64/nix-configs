{ config, lib, pkgs, ... }:
let
  symlinkPath = config.sops.defaultSymlinkPath;
  homeDir = config.home.homeDirectory;
in
{
  imports = [ ./common.nix ];

  programs.zsh = {
    enable = true;
    initContent = ''
      claude-orthos() {
        local short_id="$1"
        local base="/home/romain/Stockly"

        if [[ -z "$short_id" ]]; then
          ssh -t orthos "printf '\033]2;* Claude Code (orthos: Main)\007' && cd '$base/Main' && claude; exec \$SHELL"
          return
        fi

        if [[ ! "$short_id" =~ ^[A-Za-z0-9]{5}$ ]]; then
          echo "Error: '$short_id' is not a valid short ID (must be exactly 5 alphanumeric characters)" >&2
          return 1
        fi

        ssh -t orthos "
          dir=\$(find '$base' -maxdepth 1 -type d -name 'Main_$short_id-*' | head -1)
          if [[ -z \"\$dir\" ]]; then
            echo \"Error: no directory found for short ID '$short_id'\" >&2
            exit 1
          fi
          printf '\033]2;* Claude Code (orthos: %s)\007' \"\$(basename \"\$dir\" | sed 's/^Main_//')\"
          cd \"\$dir\" && claude; exec \$SHELL
        "
      }
      alias co='claude-orthos'
    '';
  };

  home.activation.symlinkClaudePerso = lib.hm.dag.entryAfter [ "symlinkClaudeSettings" ] ''
    # Perso MCP servers
    ASANA_TOKEN="$(cat ${symlinkPath}/code/mcp/asana-token)"
    MCP_CONFIG=$(${pkgs.jq}/bin/jq -n \
      --arg asana_token "$ASANA_TOKEN" \
      '{mcpServers: {
        asana: {
          command: "npx",
          args: ["-y", "@n0zer0d4y/asana-project-ops"],
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
