{ config, ... }:
{
  imports = [
    ./common.nix
    ../programs/server-system.nix
  ];

  config =
    let
      cfg = config.by-db;
    in
    {
      users = {
        extraUsers = {
          root = {
            hashedPassword = "$y$j9T$.H6IC0PPdWVat4f9ejoo6.$U6v8LpKV/hW4CKomjOdNk9Gz2IWrj7HWzjfRLfT7Z92";
          };
        };
      };

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
    };
}
