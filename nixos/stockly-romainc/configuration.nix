# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ host-specific, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ../common.nix
    ];

    home-manager.users.user = import ../home.nix host-specific;
  
  services.xserver.windowManager.i3.package = pkgs.i3-gaps;
  services.displayManager.autoLogin = { enable = true; user = "user"; };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput = { 
    touchpad.naturalScrolling = true;
    touchpad.middleEmulation = true;
    touchpad.tapping = true;
  };

}
