{
  services.nginx = {
    enable = true;

    virtualHosts = {
      "capucina.net" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          root = "/var/www/capucina.net/home";
        };
      };
      "es.capucina.net" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          root = "/var/www/capucina.net/escapucina";
        };
      };
      "freebox.capucina.net" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://192.168.1.254";
      };
      "nas.capucina.net" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://192.168.1.3:5000";
      };
      "comfyui.capucina.net" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "/" = {
            proxyPass = "http://192.168.1.6:8188";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_http_version 1.1;

              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "upgrade";

              proxy_set_header Host $host;
              proxy_set_header Origin $scheme://$host;

              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;

              proxy_read_timeout 86400;
            '';

          };
        };
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "bebert64@gmail.com";
  };
}
