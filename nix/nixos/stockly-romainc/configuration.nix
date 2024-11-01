{ pkgs, specialArgs, ... }:
{
  imports = [ ../common.nix ];

  home-manager = {
    users.user.imports = [ ../home.nix ];
    backupFileExtension = "bckp";
    extraSpecialArgs = specialArgs;
  };

  services = {
    xserver.windowManager.i3.package = pkgs.i3-gaps;

    displayManager.autoLogin = {
      enable = true;
      user = "user";
    };

    # Enable touchpad support (enabled default in most desktopManager).
    libinput = {
      touchpad.naturalScrolling = true;
      touchpad.middleEmulation = true;
      touchpad.tapping = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

}
