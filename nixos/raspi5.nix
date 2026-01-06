{
  config,
  ...
}:
{
  imports = [
    ./raspberry.nix
    ../programs/jellyfin
    ../programs/postgresql
    ../programs/qbittorrent
    ../programs/stash
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
          80 # http
          443 # https
          8080 # qbittorrent
          9999 # stash
        ];
      };

      # Necessary for remote installation, using --use-remote-sudo
      nix.settings.trusted-users = [ "${cfg.user.name}" ];

      sdImage.compressImage = false;

      #Used by jellyfin instances
      services = {
        meilisearch.enable = true;
      };
    };
}
