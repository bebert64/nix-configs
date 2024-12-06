{
  config,
  vscode-server,
  nixpkgs,
  ...
}:
{
  imports = [
    ./common.nix
    ../programs/configs/postgresql.nix
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

      boot.loader = {
        # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
        grub.enable = false;
        # Enables the generation of /boot/extlinux/extlinux.conf
        generic-extlinux-compatible.enable = true;
      };

      services.nginx.enable = true;
      services.nginx.virtualHosts."torrent.capucina.house" = {
        addSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8080";
          #   extraConfig =
          #     # required when the target is also TLS server with multiple hosts
          #     "proxy_ssl_server_name on;"
          #     +
          #       # required when the server wants to use HTTP Authentication
          #       "proxy_pass_header Authorization;";
        };

      };
      security.acme = {
        acceptTerms = true;
        defaults.email = "bebert64@gmail.com";
      };
    };
}
