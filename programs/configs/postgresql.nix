{ pkgs, config, ... }:
let
  cfg = config.by-db;
in
{
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
      host  all       all     192.168.1.0/24  trust
      host  all       all     127.0.0.1/32  trust
    '';
  };

  home-manager.users.${cfg.user.name}.home.packages = [
    (pkgs.writeScriptBin "restore-postgres" ''
      set -euxo pipefail

      psql -U postgres -w -f /mnt/NAS/Backup/raspi/full_dump.sql
    '')
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 5432 ];
  };
}
