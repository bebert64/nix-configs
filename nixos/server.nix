{
  config,
  vscode-server,
  nixpkgs,
  ...
}:
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

      users.users.${cfg.user.name}.linger = true;

      home-manager = {
        users.${cfg.user.name} = {
          imports = [ ../home-manager/server.nix ];
        };
      };

      services.vscode-server.enable = true;

      boot.loader = {
        # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
        grub.enable = false;
        # Enables the generation of /boot/extlinux/extlinux.conf
        generic-extlinux-compatible.enable = true;
      };

      nix.settings.trusted-users = [ "@wheel" ];
    };
}
