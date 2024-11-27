{ config
, vscode-server
, nixpkgs
, by-db
, ...
}:
{
  imports = [
    ./common.nix
    ../programs/server-system.nix
    vscode-server.nixosModules.default
    by-db.nixosModule.aarch64-linux
    "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"
  ];

  config =
    let
      cfg = config.by-db;
    in
    {
      sdImage.compressImage = false;

      home-manager = {
        users.${cfg.user.name} = {
          imports = [ ../home-manager/server.nix ];
        };
      };

      by-db-pkgs = {
        wallpapers-manager = {
          wallpapersDir = "/mnt/NAS/Wallpapers";
          services.download = {
            enable = true;
            runAt = "*-*-* 18:00:00";
          };
          ffsync = {
            username = "bebert64@gmail.com";
            passwordPath = "${config.home-manager.users.${cfg.user.name}.sops.secrets."ffsync/bebert64".path}";
          };
        };
      };

      services.vscode-server.enable = true;

      # Bootloader.
      boot.loader = {
        # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
        grub.enable = false;
        # Enables the generation of /boot/extlinux/extlinux.conf
        generic-extlinux-compatible.enable = true;
      };

      nix.settings.trusted-users = [ "@wheel" ];
    };
}
