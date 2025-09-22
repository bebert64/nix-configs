{
  config,
  vscode-server,
  nixpkgs,
  ...
}:
{
  imports = [
    ./common.nix
    ../programs/server-global.nix
    ../programs/dnsmasq.nix
    ../programs/jellyfin.nix
    ../programs/nginx.nix
    ../programs/postgresql.nix
    ../programs/qbittorrent
    ../programs/stash
    vscode-server.nixosModules.default
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

      services.vscode-server.enable = true;

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
    };
}
