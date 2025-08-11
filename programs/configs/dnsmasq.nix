{
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = true;
    settings = {
      address = [ "/.capucina.net/192.168.1.2" ];
      domain-needed = true;
      bogus-priv = true;
      filterwin2k = true;
    };
  };
}
