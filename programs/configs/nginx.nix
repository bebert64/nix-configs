{
  services.nginx = {
    enable = true;
    virtualHosts."freebox.capucina.house" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://192.168.1.254";
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "bebert64@gmail.com";
  };
}
