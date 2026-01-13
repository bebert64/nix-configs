{
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = true;
    settings = {
      address = [ "/.capucina.net/192.168.1.2" ];
      listen-address = [
        "127.0.0.1"
        "192.168.1.2"
        "10.200.200.1"
      ];
    };
  };

  networking.firewall.interfaces.end0 = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [
      53
      67
    ];
  };
}
