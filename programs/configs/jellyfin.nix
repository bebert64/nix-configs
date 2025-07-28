{
  pkgs,
  ...
}:
{
  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-ffmpeg
    pkgs.jellyfin-web
    pkgs.youtube-dl
  ];

  services = {
    jellyfin.enable = true;
    nginx.virtualHosts."jellyfin.capucina.house" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8096";
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
        proxyPass = "http://127.0.0.1:8096";
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
  };
}
