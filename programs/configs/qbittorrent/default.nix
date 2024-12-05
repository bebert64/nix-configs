{
  pkgs,
  lib,
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
        Type = "exec";
        ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };

  home.activation.symlinkQbittorrentConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ln -sf ${config.home.homeDirectory}/${config.by-db.nixConfigsRepo}/programs/configs/qbittorrent/qBittorrent.conf ${config.home.homeDirectory}/.config/qBittorrent/qbittorrent.conf
  '';
}
