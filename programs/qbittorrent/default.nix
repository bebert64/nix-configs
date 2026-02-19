{
  pkgs,
  config,
  ...
}:
{
  systemd.user = {
    enable = true;
    services.qbittorrent = {
      Unit = {
        Description = "QBittorrent server";
      };
      Service = {
        Type = "simple";
        Restart = "on-failure";
        ExecStart = "${pkgs.bash}/bin/bash -c 'while [ ! -d ${config.byDb.paths.nasBase} ]; do sleep 1; done; ${pkgs.qbittorrent-nox}/bin/qbittorrent-nox'";

      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
