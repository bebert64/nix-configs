{ config, lib, ... }:
let
  homeDir = config.home.homeDirectory;
  inherit (config.byDb.paths) nixPrograms;
in
{
  imports = [ ./common.nix ];

  home.activation.symlinkClaudeStockly = lib.hm.dag.entryAfter [ "symlinkClaudeSettings" ] ''
    # Stockly rules
    ln -sfT ${nixPrograms}/claude-code/rules/stockly ${homeDir}/.claude/rules/stockly
  '';
}
