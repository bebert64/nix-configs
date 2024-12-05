{ pkgs, ... }:
{
  systemd.user = {
    enable = true;
    services.stash = {
      Unit = {
        Description = "QBittorrent server";
      };
      Service = {
        Type = "exec";
        ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
