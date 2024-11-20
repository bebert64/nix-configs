{ pkgs, ... }:
{
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
      host  all       all     192.168.1.0/24  trust
    '';
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 5432 ];
  };
}
