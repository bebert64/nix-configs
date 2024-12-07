{
  services.nginx = {
    enable = true;

    virtualHosts = {
      "capucina.house" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          root = "/var/www/capucina.house/home";
        };
      };
      "es.capucina.house" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          root = "/var/www/capucina.house/escapucina";
        };
      };
      "freebox.capucina.house" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://192.168.1.254";
      };
      "nas.capucina.house" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://192.168.1.3:5000";
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "bebert64@gmail.com";
  };
}
