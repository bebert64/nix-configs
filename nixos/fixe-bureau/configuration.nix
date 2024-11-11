{ pkgs, specialArgs, ... }:
{
  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];

  # Configuration options that are not standard NixOS, but were defined by Stockly
  stockly = {
    acer-quanta-webcam-fix = false;
    ui = null;
    nvidia = false;
    auto-update.enable = true; # See auto-update.nix for doc
    keyboard-layout = "fr";
  };

  home-manager =
    let
      username = "romain";
    in
    {
      users.${username} = {
        imports = [ ../../home-manager/home.nix ];
        by-db.username = "${username}";
      };
      backupFileExtension = "bckp";
      extraSpecialArgs = specialArgs;

    };

  services = {
    xserver.windowManager.i3.package = pkgs.i3-gaps;
  };

  nixpkgs.config.allowUnfree = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
