# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

# This configuration file is not part of the default system, instead it is used to factor
# configurations on my different computers together

{
  pkgs,
  flake-inputs,
  host-specific,
  ...
}:

{
  imports = [ ./common.nix ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.nixPath = [ "nixpkgs=${flake-inputs.nixpkgs.outPath}" ];

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure console keymap
  console.keyMap = "fr";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.defaultUserShell = pkgs.zsh;
  users.users.romain = {
    isNormalUser = true;
    description = "romain";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };
  home-manager.users.romain = import ./home.nix host-specific;

  services.displayManager.autoLogin = {
    enable = true;
    user = "romain";
  };

  nixpkgs.config.allowUnfree = true;

}
