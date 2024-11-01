# This is the old config for my fix-bureau and stockly-romainc before
# the "standard" Stockly's config
# Can be used for reference when recreating a fixe-bureau config one day

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
