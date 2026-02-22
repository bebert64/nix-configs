{
  lib,
  config,
  ...
}:
let
  # Instance names
  jellyfinInstance1 = "guitar";
  jellyfinInstance2 = "media";

  # Wraps a virtual host definition with Authelia forward-auth:
  # nginx sends an auth subrequest to Authelia on every request.
  # Authelia's access_control handles LAN bypass (192.168.1.0/24 → bypass)
  # and requires one-factor auth for WAN clients via a login form.
  # Unauthenticated WAN users are redirected to https://auth.capucina.net.
  mkProtectedVirtualHost =
    attrs:
    lib.recursiveUpdate attrs {
      extraConfig = ''
        auth_request /_authelia;
        error_page 401 =302 https://auth.capucina.net/?rd=$scheme://$http_host$request_uri;

        auth_request_set $user $upstream_http_remote_user;
        auth_request_set $groups $upstream_http_remote_groups;
        auth_request_set $name $upstream_http_remote_name;
        auth_request_set $email $upstream_http_remote_email;
      ''
      + (attrs.extraConfig or "");

      locations."/_authelia" = {
        proxyPass = "http://127.0.0.1:9091/api/authz/auth-request";
        extraConfig = ''
          internal;
          proxy_set_header X-Original-Method $request_method;
          proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
          proxy_set_header X-Forwarded-For $remote_addr;
          proxy_set_header Content-Length "";
          proxy_set_header Connection "";
          proxy_pass_request_body off;
        '';
      };
    };

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

    # Map for WebSocket connection upgrade
    appendHttpConfig = ''
      map $http_upgrade $connection_upgrade {
        default upgrade;
        "" close;
      }
    '';

    virtualHosts = {
      "auth.capucina.net" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:9091";
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_buffering off;
          '';
        };
      };

      "capucina.net" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          root = "/var/www/capucina.net/home";
        };
      };

      "bazarr.capucina.net" = mkProtectedVirtualHost {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://192.168.1.7:6767";
          extraConfig = ''
            proxy_set_header   Host $host;
            proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header   X-Forwarded-Host $host;
            proxy_set_header   X-Forwarded-Proto $scheme;
            proxy_set_header   Upgrade $http_upgrade;
            proxy_set_header   Connection $http_connection;
            proxy_redirect     off;
            proxy_http_version 1.1;
          '';
        };
      };

      "comfyui.capucina.net" = mkProtectedVirtualHost {
        enableACME = true;
        forceSSL = true;
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
          alias = "${config.byDb.hmUser.byDb.paths.nasBase}/Guitare/Tabs/";
        };
      };
      "${jellyfinInstance2}.capucina.net" = mkJellyfinVirtualHost 8097;

      "nas.capucina.net" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://192.168.1.3:5000";
      };

      "plex.capucina.net" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://192.168.1.7:32400";
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $host;
            proxy_http_version 1.1;
          '';
        };
      };

      "prowlarr.capucina.net" = mkProtectedVirtualHost {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://192.168.1.7:9696";
          extraConfig = ''
            proxy_http_version 1.1;
            proxy_set_header   Host $host;
            proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header   X-Forwarded-Host $host;
            proxy_set_header   X-Forwarded-Proto $scheme;
            proxy_set_header   Upgrade $http_upgrade;
            proxy_set_header   Connection $http_connection;
            proxy_redirect off;
          '';
        };
      };

      "radarr.capucina.net" = mkProtectedVirtualHost {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://192.168.1.7:7878";
          extraConfig = ''
            proxy_set_header   Host $host;
            proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header   X-Forwarded-Host $host;
            proxy_set_header   X-Forwarded-Proto $scheme;
            proxy_set_header   Upgrade $http_upgrade;
            proxy_set_header   Connection $http_connection;
            proxy_redirect     off;
            proxy_http_version 1.1;
          '';
        };
      };

      "sonarr.capucina.net" = mkProtectedVirtualHost {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://192.168.1.7:8989";
          extraConfig = ''
            proxy_set_header   Host $host;
            proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header   X-Forwarded-Host $host;
            proxy_set_header   X-Forwarded-Proto $scheme;
            proxy_set_header   Upgrade $http_upgrade;
            proxy_set_header   Connection $http_connection;
            proxy_redirect     off;
            proxy_http_version 1.1;
          '';
        };
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

      "torrent.capucina.net" = mkProtectedVirtualHost {
        enableACME = true;
        forceSSL = true;

        root = "/var/www/capucina.net/qbittorrent";

        locations = {
          "/" = {
            proxyPass = "http://192.168.1.7:8080";
            extraConfig = ''
              proxy_http_version 1.1;
              proxy_set_header   Host               $proxy_host;
              proxy_set_header   X-Forwarded-For    $proxy_add_x_forwarded_for;
              proxy_set_header   X-Forwarded-Host   $http_host;
              proxy_set_header   X-Forwarded-Proto  $scheme;

              proxy_connect_timeout 1s;
              proxy_read_timeout 3s;
              proxy_send_timeout 3s;
              proxy_intercept_errors on;
              error_page 502 503 504 /down.html;
            '';
          };
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
