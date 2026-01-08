{
  config,
  ...
}:
{
  imports = [
    ./raspberry.nix
    ../programs/postgresql
  ];

  config =
    let
      cfg = config.by-db;
    in
    {
      home-manager.users.${cfg.user.name}.imports = [ ../home-manager/raspi5.nix ];

      networking.firewall = {
        enable = true;
        allowedTCPPorts = [
          80 # nginx redirect for plex
          8080 # qbittorrent
          8096 # jellyfin guitar
          8097 # jellyfin media
          9999 # stash
          32400 # plex
        ];
      };

      # Simple nginx redirect from port 80 to Plex on port 32400
      services.nginx = {
        enable = true;
        virtualHosts."plex.capucina.net" = {
          locations."/" = {
            return = "307 http://$host:32400$request_uri";
          };
        };
        # Also handle requests to the IP directly
        virtualHosts."_" = {
          serverName = "_";
          locations."/" = {
            return = "307 http://$host:32400$request_uri";
          };
        };
      };

      #Used by jellyfin instances
      services = {
        meilisearch.enable = true;
      };

      # Might be needed for stash, not sure
      nixpkgs.config.allowUnsupportedSystem = true;
    };
}
