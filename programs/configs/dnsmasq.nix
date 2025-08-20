{
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = true;
    settings = {
      address = [ "/.capucina.net/192.168.1.2" ];
      listen-address = [
        "127.0.0.1"
        "192.168.1.2"
      ];
      domain-needed = true;
      bogus-priv = true;
      filterwin2k = true;
    };
  };
}
