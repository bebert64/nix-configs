{
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = true;
    settings = {
      address = [
        "/.capucina.net/192.168.1.2"
        "/plex.capucina.net/192.168.1.7"
      ];
      listen-address = [
        "127.0.0.1"
        "192.168.1.2"
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
