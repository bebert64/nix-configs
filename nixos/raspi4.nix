{
  config,
  nixpkgs,
  ...
}:
{
  imports = [
    ./raspberry.nix
    ../programs/dnsmasq
    ../programs/nginx
    "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"
  ];

  config =
    let
      cfg = config.by-db;
    in
    {
      home-manager.users.${cfg.user.name}.imports = [ ../home-manager/raspi4.nix ];

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [
            80 # http
            443 # https
            5432 # PostgreSQL forwarding
            51820 # VPN
          ];
        };

        # Forward port 5432 to 192.168.1.7:5432
        nat = {
          enable = true;
          externalInterface = "eth0";
          forwardPorts = [
            {
              sourcePort = 5432;
              destination = "192.168.1.7:5432";
              proto = "tcp";
            }
          ];
        };

        # VPN server
        wireguard = {
          enable = true;
          interfaces = {
            wg0 = {
              ips = [ "10.200.200.1/24" ];
              listenPort = 51820;
              privateKeyFile = "/etc/wireguard/privatekey";
              peers = [
                {
                  publicKey = "RkpsY1WJPiyZAj+l/QoY8qGW75rbQBmjAiVphuowkSc=";
                  allowedIPs = [ "10.200.200.2/32" ]; # VPN IP for this client
                }
              ];
            };
          };
        };

      };
    };
}
