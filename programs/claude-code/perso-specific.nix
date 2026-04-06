{ config, lib, ... }:
let
  homeDir = config.home.homeDirectory;
  inherit (config.byDb.paths) nixPrograms;
in
{
  home.activation.symlinkClaudePerso = lib.hm.dag.entryAfter [ "symlinkClaudeSettings" ] ''
    # Perso skills
    for skill in ${nixPrograms}/claude-code/skills/perso/*/; do
      ln -sfT "$skill" ${homeDir}/.claude/skills/$(basename "$skill")
    done
  '';
}
