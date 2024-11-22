{ config, vscode-server, nixpkgs, ... }:
{
  imports = [
    ./common.nix
    ../programs/server-system.nix
    vscode-server.nixosModules.default
    "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"
  ];

  config =
    let
      cfg = config.by-db;
    in
    {
      sdImage.compressImage = false;

      # users = {
      #   extraUsers = {
      #     root = {
      #       hashedPassword = "$y$j9T$.H6IC0PPdWVat4f9ejoo6.$U6v8LpKV/hW4CKomjOdNk9Gz2IWrj7HWzjfRLfT7Z92";
      #     };
      #   };
      # };

      home-manager = {
        users.${cfg.user.name} = {
          imports = [ ../home-manager/server.nix ];
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
