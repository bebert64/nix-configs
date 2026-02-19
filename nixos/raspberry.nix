{
  config,
  nixpkgs,
  ...
}:
{
  imports = [
    ./common.nix
    "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"
  ];

  config =
    let
      byDbNixos = config.by-db;
    in
    {
      # Necessary for user's systemd services to start at boot (before user logs in)
      users.users.${byDbNixos.user.name}.linger = true;

      sdImage.compressImage = false;
    };
}
