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
      userConfig = config.byDb.user;
    in
    {
      # Necessary for user's systemd services to start at boot (before user logs in)
      users.users.${userConfig.name}.linger = true;

      sdImage.compressImage = false;
    };
}
