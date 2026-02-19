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
      byDbNixos = config.byDb;
    in
    {
      home-manager.users.${byDbNixos.user.name}.imports = [ ../home-manager/raspi4.nix ];

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [
            80 # http
            443 # https
            5432 # PostgreSQL forwarding
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

      };
    };
}
