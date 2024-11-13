{
  pkgs,
  specialArgs,
  lib,
  config,
  ...
}:
let
  user = config.by-db.user;
in
{
  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];

  home-manager = {
    users.${user.name}.by-db = {
      scripts = {
        set-headphones = "set-sink-port 56 '[Out] Headphones'";
        set-speaker = "set-sink-port 56 '[Out] Speaker'";
      };
      polybar = {
        is-headphones-on-regex = "Active Port.*Headphones";
      };
    };
  };

  networking = {
    hostName = "fixe-bureau";
    #   extraHosts = ''
    #    127.0.0.1 mafreebox.freebox.fr
    #  '';
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
