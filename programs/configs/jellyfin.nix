{
  pkgs,
  config,
  ...
}:
let
  cfgUser = config.home-manager.users.${config.by-db.user.name};
in
{
  home-manager.users.${config.by-db.user.name} = {
    home = {
      packages = [
        pkgs.jellyfin
        pkgs.jellyfin-ffmpeg
        pkgs.jellyfin-web
        pkgs.yt-dlp
      ];

      systemd.user = {
        enable = true;
        services.jellyfin = {
          Unit = {
            Description = "Jellyfin";
          };
          Service = {
            Type = "exec";
            ExecStart = "
				${pkgs.jellyfin}/bin/jellyfin
				--add-flags --ffmpeg=${pkgs.jellyfin-ffmpeg}/bin/ffmpeg
				--add-flags --webdir=${pkgs.jellyfin-web}/share/jellyfin-web
			";
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
          Environment = "PATH=/run/current-system/sw/bin/:${cfgUser.home.homeDirectory}/.nix-profile/bin/";
        };
      };
    };
  };

  services = {
    nginx.virtualHosts."jellyfin.capucina.net" = {
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
