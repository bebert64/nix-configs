{
  pkgs,
  config,
  home-manager,
  ...
}:
let
  cfgUser = config.home-manager.users.${config.by-db.user.name};
in
{
  home-manager.users.${config.by-db.user.name} = {
    systemd.user = {
      enable = true;
      services.qbittorrent = {
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

    home.activation.symlinkQbittorrentConfig = home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ln -sf ${cfgUser.home.homeDirectory}/${cfgUser.by-db.nixConfigsRepo}/programs/configs/qbittorrent/qBittorrent.conf ${cfgUser.home.homeDirectory}/.config/qBittorrent/qBittorrent.conf
    '';
  };

  services.nginx.virtualHosts."torrent.capucina.house" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8080";
      extraConfig = ''
        proxy_http_version 1.1;
        # headers recognized by qBittorrent
        proxy_set_header   Host               $proxy_host;
        proxy_set_header   X-Forwarded-For    $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Host   $http_host;
        proxy_set_header   X-Forwarded-Proto  $scheme;
      '';
    };
  };
}
