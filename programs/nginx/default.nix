{
  lib,
  ...
}:
let
  # Instance names
  jellyfinInstance1 = "guitar";
  jellyfinInstance2 = "media";

  # Helper function to create nginx virtual host for Jellyfin
  mkJellyfinVirtualHost = port: {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://192.168.1.7:${toString port}";
      extraConfig = ''
        # Proxy main Jellyfin traffic
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Protocol $scheme;
        proxy_set_header X-Forwarded-Host $http_host;

        # Disable buffering when the nginx proxy gets very resource heavy upon streaming
        proxy_buffering off;
      '';
    };
    locations."/socket" = {
      proxyPass = "http://192.168.1.7:${toString port}";
      extraConfig = ''
        # Proxy Jellyfin Websockets traffic
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Protocol $scheme;
        proxy_set_header X-Forwarded-Host $http_host;
      '';
    };
  };
in
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

      "comfyui.capucina.net" = {
        enableACME = true;
        forceSSL = true;
        # Web UI and WebSocket reverse proxy to ComfyUI host
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
        locations = {
          "/" = {
            proxyPass = "http://192.168.1.6:8188";
            proxyWebsockets = true;
          };
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

      "${jellyfinInstance1}.capucina.net" = lib.recursiveUpdate (mkJellyfinVirtualHost 8096) {
        locations."/tabs/" = {
          alias = "/mnt/NAS/Guitare/Tabs/";
        };
      };
      "${jellyfinInstance2}.capucina.net" = mkJellyfinVirtualHost 8097;

      "nas.capucina.net" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://192.168.1.3:5000";
      };

      "stash.capucina.net" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://192.168.1.7:9999";
          extraConfig = ''
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_read_timeout 60000s;
          '';
        };
      };

      "torrent.capucina.net" = {
        enableACME = true;
        forceSSL = true;

        # Serve the "down" page from a static path
        root = "/var/www/capucina.net/qbittorrent"; # directory for down.html

        locations = {
          "/" = {
            proxyPass = "http://192.168.1.7:8080";
            extraConfig = ''
              proxy_http_version 1.1;
              # headers recognized by qBittorrent
              proxy_set_header   Host               $proxy_host;
              proxy_set_header   X-Forwarded-For    $proxy_add_x_forwarded_for;
              proxy_set_header   X-Forwarded-Host   $http_host;
              proxy_set_header   X-Forwarded-Proto  $scheme;

              # Detect if backend is down and serve down.html
              proxy_connect_timeout 1s;
              proxy_read_timeout 3s;
              proxy_send_timeout 3s;
              proxy_intercept_errors on;
              error_page 502 503 504 /down.html;
            '';
          };
          # Serve static down.html page
          "/down.html" = {
            root = "/var/www/capucina.net/qbittorrent";
          };
        };
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/www/capucina.net/qbittorrent 0755 root root -"
    "C /var/www/capucina.net/qbittorrent/down.html 0644 root root - ${./qbittorrent-down.html}"
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "bebert64@gmail.com";
  };
}
