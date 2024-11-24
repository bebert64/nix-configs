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


  users.users.postgres = {
    hashedPassword = "$y$j9T$2SPWxfDGbh85U9jNsQgHL1$ssaNLjhJx1dV5jgvyhBkURJeWTm5iYvF6QZvFIGMPtD";
  };
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 5432 ];
  };
}
