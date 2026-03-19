{
  pkgs,
  pkgsUnstable,
  ...
}:
let
  claudeWithVoice = pkgs.writeShellScriptBin "claude" ''
    # PulseAudio forwarding for Claude Code voice mode on monsters
    if [ -S /tmp/pulse-forward ]; then
      export PULSE_SERVER=unix:/tmp/pulse-forward
    fi
    exec ${pkgsUnstable.claude-code}/bin/claude "$@"
  '';
in
{
  home.packages = [
    claudeWithVoice
    pkgs.sox
  ];
}
