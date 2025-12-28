{
  config,
  nixpkgs,
  ...
}:
{
  imports = [
    ./common.nix
    ../programs/dnsmasq
    # ../programs/jellyfin  # Excluded: uses ffmpeg_7-rpi which doesn't handle cross-compilation
    ../programs/nginx
    ../programs/postgresql
    ../programs/qbittorrent
    # ../programs/stash  # Excluded: uses ffmpeg_7-rpi which doesn't handle cross-compilation
    "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"
  ];

  config =
    let
      cfg = config.by-db;
    in
    {
      # Necessary for user's systemd services to start at boot (before user logs in)
      users.users.${cfg.user.name}.linger = true;

      home-manager.users.${cfg.user.name}.imports = [ ../home-manager/server.nix ];

      networking.firewall = {
        enable = true;
        allowedTCPPorts = [
          80 # http
          443 # https
          8080 # qbittorrent
          # 9999 # stash - disabled
        ];
      };

      # Necessary for remote installation, using --use-remote-sudo
      nix.settings.trusted-users = [ "${cfg.user.name}" ];

      sdImage.compressImage = false;
    };
}
