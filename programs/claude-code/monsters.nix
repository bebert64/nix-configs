{ config, lib, ... }:
let
  homeDir = config.home.homeDirectory;
  nixPrograms = config.byDb.paths.nixPrograms;
in
{
  imports = [ ./common.nix ];

  home.activation.symlinkClaudeStockly = lib.hm.dag.entryAfter [ "symlinkClaudeSettings" ] ''
    # Stockly rules
    ln -sfT ${nixPrograms}/claude-code/rules/stockly ${homeDir}/.claude/rules/stockly

    # Stockly docs
    ln -sfT ${nixPrograms}/claude-code/docs/stockly ${homeDir}/.claude/docs/stockly

  '';
}
