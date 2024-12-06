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
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8080";
          extraConfig = ''
            proxy_http_version 1.1;
            # headers recognized by qBittorrent
            proxy_set_header   Host               $proxy_host;
            proxy_set_header   X-Forwarded-For    $proxy_add_x_forwarded_for;
            proxy_set_header   X-Forwarded-Host   $http_host;
            proxy_set_header   X-Forwarded-Proto  $scheme;
          '';
          # "proxy_http_version 1.1;"
          # # headers recognized by qBittorrent
          # + "proxy_set_header   Host               $proxy_host;"
          # + "proxy_set_header   X-Forwarded-For    $proxy_add_x_forwarded_for;"
          # + "proxy_set_header   X-Forwarded-Host   $http_host;"
          # + "proxy_set_header   X-Forwarded-Proto  $scheme;";
        };

      };
      services.nginx.virtualHosts."stash.capucina.house" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:9999";
          extraConfig = ''
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_read_timeout 60000s;
          '';
        };

      };
      security.acme = {
        acceptTerms = true;
        defaults.email = "bebert64@gmail.com";
      };
    };
}
