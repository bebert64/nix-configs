{ pkgs, ... }:
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

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 5432 ];
  };
}
