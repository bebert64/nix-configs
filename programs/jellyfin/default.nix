{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfgUser = config.home-manager.users.${config.by-db.user.name};
  userHome = cfgUser.home.homeDirectory;

  # Instance names
  jellyfinInstance1 = "guitar";
  jellyfinInstance2 = "media";

  # Helper function to create a Jellyfin service
  # instanceName: base name for the instance (e.g., "jellyfin", "jellyfin2")
  # port: HTTP port for the service
  mkJellyfinService =
    instanceName: port:
    let
      dataDir = "${userHome}/.local/share/${instanceName}";
      configDir = "${userHome}/.config/${instanceName}";
    in
    {
      Unit = {
        Description = "Jellyfin ${instanceName}";
      };
      Service = {
        Type = "simple";
        Restart = "on-failure";
        ExecStart = "${pkgs.jellyfin}/bin/jellyfin --configdir ${configDir}";
        Environment = [
          "PATH=/run/current-system/sw/bin/:${userHome}/.nix-profile/bin/"
          "JELLYFIN_DATA_DIR=${dataDir}"
        ];
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

  # Helper function to create nginx virtual host for Jellyfin
  mkJellyfinVirtualHost = port: {
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
      services.${jellyfinInstance1} = mkJellyfinService jellyfinInstance1 8096;
      services.${jellyfinInstance2} = mkJellyfinService jellyfinInstance2 8097;
    };
  };

  services = {
    # nginx.virtualHosts."${jellyfinInstance1}.capucina.net" = mkJellyfinVirtualHost 8096;
    nginx.virtualHosts."${jellyfinInstance1}.capucina.net" =
      lib.recursiveUpdate (mkJellyfinVirtualHost 8096)
        {
          locations."/tabs/" = {
            alias = "/mnt/NAS/Guitare/Tabs/";
          };
        };
    nginx.virtualHosts."${jellyfinInstance2}.capucina.net" = mkJellyfinVirtualHost 8097;

    meilisearch.enable = true;
  };
}
