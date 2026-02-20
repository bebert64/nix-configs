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
      userConfig = config.byDb.user;
    in
    {
      home-manager.users.${userConfig.name}.imports = [ ../home-manager/raspi5.nix ];

      networking.firewall = {
        enable = true;
        allowedTCPPorts = [
          8080 # qbittorrent
          8096 # jellyfin guitar
          8097 # jellyfin media
          9999 # stash
          32400 # plex
        ];
      };

      #Used by jellyfin instances
      services = {
        meilisearch.enable = true;
      };

      # Might be needed for stash, not sure
      nixpkgs.config.allowUnsupportedSystem = true;
    };
}
