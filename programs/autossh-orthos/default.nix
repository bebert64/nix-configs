{ pkgs, ... }:
{
  home.packages = [ pkgs.autossh ];

  systemd.user.services.autossh-orthos = {
    Unit = {
      Description = "Persistent reverse SSH tunnel to orthos for notifications";
      After = [ "network-online.target" ];
    };
    Install.WantedBy = [ "default.target" ];
    Service = {
      # AUTOSSH_GATETIME=0: don't require the connection to be up for N seconds before considering it "established"
      # AUTOSSH_PORT=0: disable autossh's own monitoring port, rely on ServerAlive instead
      Environment = [
        "AUTOSSH_GATETIME=0"
        "AUTOSSH_PORT=0"
      ];
      ExecStart = builtins.concatStringsSep " " [
        "${pkgs.autossh}/bin/autossh"
        "-M 0" # no monitor port (using ServerAlive instead)
        "-N" # no remote command
        "-R 2222:localhost:22" # reverse tunnel: orthos:2222 -> local:22
        "-o ServerAliveInterval=30"
        "-o ServerAliveCountMax=3"
        "-o ExitOnForwardFailure=yes"
        "-o BatchMode=yes"
        "orthos"
      ];
      Restart = "always";
      RestartSec = "5s";
    };
  };
}
