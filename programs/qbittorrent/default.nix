{
  pkgs,
  config,
  ...
}:
{
  home-manager.users.${config.by-db.user.name} = {
    systemd.user = {
      enable = true;
      services.qbittorrent = {
        Unit = {
          Description = "QBittorrent server";
        };
        Service = {
          Type = "simple";
          Restart = "on-failure";
          ExecStart = "${pkgs.bash}/bin/bash -c 'while [ ! -d /mnt/NAS ]; do sleep 1; done; ${pkgs.qbittorrent-nox}/bin/qbittorrent-nox'";

        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
  };
}
