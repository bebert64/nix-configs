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
      cfg = config.by-db;
    in
    {
      # Necessary for user's systemd services to start at boot (before user logs in)
      users.users.${cfg.user.name}.linger = true;

      sdImage.compressImage = false;
    };
}
