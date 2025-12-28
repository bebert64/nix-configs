{
  nixos-raspberrypi,
  nixpkgs,
  lib,
  ...
}:
{
  imports = [
    (
      { ... }:
      {
        imports = with nixos-raspberrypi.nixosModules; [
          raspberry-pi-5.base
          raspberry-pi-5.page-size-16k
          raspberry-pi-5.display-vc4
        ];
      }
    )
    ../../nixos/common.nix
    ../../programs/dnsmasq
    # ../../programs/jellyfin  # Excluded: uses ffmpeg_7-rpi which doesn't handle cross-compilation
    ../../programs/nginx
    ../../programs/postgresql
    ../../programs/qbittorrent
    # ../../programs/stash  # Excluded: uses ffmpeg_7-rpi which doesn't handle cross-compilation
    ./hardware-configuration.nix
    (
      { ... }:
      {
        imports = [
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"
        ];
      }
    )
  ];

  by-db.user = {
    name = "romain";
    description = "Romain";
  };

  networking = {
    hostName = "raspi";
  };

  # Server configuration (from server.nix, excluding jellyfin and stash)
  users.users.romain.linger = true;
  home-manager.users.romain.imports = [ ../../home-manager/server.nix ];
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80
      443
      8080
    ]; # Excluded 9999 (stash)
  };
  nix.settings.trusted-users = [ "romain" ];
  sdImage.compressImage = false;
}
