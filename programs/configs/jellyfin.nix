{
  pkgs,
  ...
}:
{
  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-ffmpeg
    pkgs.jellyfin-web
  ];

  services = {
    jellyfin.enable = true;
    nginx.virtualHosts."jellyfin.capucina.house" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8096";
      };
    };
  };
}
