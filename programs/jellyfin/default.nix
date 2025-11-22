{
  pkgs,
  config,
  ...
}:
let
  cfgUser = config.home-manager.users.${config.by-db.user.name};
  userHome = cfgUser.home.homeDirectory;

  # Helper function to create a Jellyfin service
  mkJellyfinService = name: port: dataDir: {
    Unit = {
      Description = "Jellyfin ${name}";
    };
    Service = {
      Type = "simple";
      Restart = "on-failure";
      ExecStart = "${pkgs.jellyfin}/bin/jellyfin";
      Environment = [
        "PATH=/run/current-system/sw/bin/:${userHome}/.nix-profile/bin/"
        "JELLYFIN_DATA_DIR=${dataDir}"
        "JELLYFIN_HTTP_PORT=${toString port}"
      ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # Helper function to create nginx virtual host for Jellyfin
  mkJellyfinVirtualHost = hostname: port: {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
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
      proxyPass = "http://127.0.0.1:${toString port}";
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
  home-manager.users.${config.by-db.user.name} = {
    home = {
      packages = [
        pkgs.jellyfin
        pkgs.ffmpeg
        pkgs.jellyfin-web
        pkgs.yt-dlp
      ];
    };

    systemd.user = {
      enable = true;
      # First Jellyfin instance (default)
      services.jellyfin = mkJellyfinService "Instance 1" 8096 "${userHome}/.local/share/jellyfin";
      # Second Jellyfin instance
      services.jellyfin2 = mkJellyfinService "Instance 2" 8097 "${userHome}/.local/share/jellyfin2";
    };
  };

  services = {
    # First Jellyfin instance virtual host
    nginx.virtualHosts."jellyfin.capucina.net" = mkJellyfinVirtualHost "jellyfin.capucina.net" 8096 // {
      locations."/tabs/" = {
        alias = "/mnt/NAS/Guitare/Tabs/";
      };
    };
    # Second Jellyfin instance virtual host (you can change the hostname as needed)
    nginx.virtualHosts."jellyfin2.capucina.net" = mkJellyfinVirtualHost "jellyfin2.capucina.net" 8097;

    meilisearch.enable = true;
  };
}
