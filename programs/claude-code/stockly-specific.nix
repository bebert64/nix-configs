{ config, lib, ... }:
let
  homeDir = config.home.homeDirectory;
  inherit (config.byDb.paths) nixPrograms;
in
{
  home.activation.symlinkClaudeStockly = lib.hm.dag.entryAfter [ "symlinkClaudeSettings" ] ''
    # Stockly rules
    ln -sfT ${nixPrograms}/claude-code/rules/stockly ${homeDir}/.claude/rules/stockly

    # Stockly skills
    for skill in ${nixPrograms}/claude-code/skills/stockly/*/; do
      ln -sfT "$skill" ${homeDir}/.claude/skills/$(basename "$skill")
    done

    # Stockly commands
    for cmd in ${nixPrograms}/claude-code/commands/stockly/*.md; do
      ln -sfT "$cmd" ${homeDir}/.claude/commands/$(basename "$cmd")
    done

    # Stockly docs (each item individually to merge with global docs)
    for item in ${nixPrograms}/claude-code/docs/stockly/*/; do
      ln -sfT "$item" ${homeDir}/.claude/docs/$(basename "$item")
    done
    for item in ${nixPrograms}/claude-code/docs/stockly/*.md; do
      [ -f "$item" ] && ln -sfT "$item" ${homeDir}/.claude/docs/$(basename "$item")
    done

    # Script
    mkdir -p ${homeDir}/Stockly/.claude
    ln -sf ${nixPrograms}/claude-code/scripts/parse_qtt.py ${homeDir}/Stockly/.claude/parse_qtt.py
  '';
}
