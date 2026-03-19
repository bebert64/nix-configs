{
  pkgs,
  pkgsUnstable,
  ...
}:
let
  claudeWithVoice = pkgs.writeShellScriptBin "claude" ''
    export PULSE_SERVER=unix:/tmp/pulse-forward
    exec ${pkgsUnstable.claude-code}/bin/claude "$@"
  '';
in
{
  home.packages = [
    claudeWithVoice
    pkgs.sox
  ];
}
