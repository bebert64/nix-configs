{
  config,
  home-manager,
  vscode-server,
  ...
}:
let
  user = config.by-db.user;
  homeDirectory = "/home/${user.name}";
in
{
  imports = [
    ../../nixos/workstation.nix
    ./hardware-configuration.nix
    vscode-server.nixosModules.default
  ];

  by-db = {
    user = {
      name = "romain";
      description = "Romain";
    };
    nix-cores = 4;
    nix-max-jobs = 2;
    nix-high-ram = "22G";
    nix-max-ram = "24G";
  };

  home-manager.users.${user.name} = {
    by-db = {
      minutes-before-lock = 5;
      minutes-from-lock-to-sleep = 15;
      screens = {
        primary = "HDMI-0";
      };
      isHeadphonesOnCommand = "pactl get-default-sink | grep alsa_output.pci-0000_00_1b.0.analog-stereo";
      setHeadphonesCommand = "set-default-sink alsa_output.pci-0000_00_1b.0.analog-stereo";
      setSpeakerCommand = "set-default-sink alsa_output.pci-0000_01_00.1.hdmi-stereo-extra2";
    };

    home.activation = {
      symlinkAutoFixVsCodeServerService = home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p ${homeDirectory}/.config/systemd/user/
        ln -sf /run/current-system/etc/systemd/user/auto-fix-vscode-server.service ${homeDirectory}/.config/systemd/user/
      '';
    };
  };

  networking = {
    hostName = "salon";
    interfaces.enp12s0.wakeOnLan.enable = true;
  };

  services = {
    vscode-server = {
      enable = true;
      installPath = [
        "${homeDirectory}/.vscode-server"
        "${homeDirectory}/.vscode-server-oss"
        "${homeDirectory}/.vscode-server-insiders"
        "${homeDirectory}/.cursor-server"
      ];
    };

  };
  # services.xserver.displayManager.lightdm.greeters.gtk = {
  #   extraConfig = "display-setup-script=xrandr -s 1920x1080";
  # };

  #   environment.etc."lightdm/lightdm.conf".text = lib.mkForce ''
  #     [LightDM]
  #     greeter-user = lightdm
  #     greeters-directory = /nix/store/bmj7d50dgyxd7wxfidyiicv2747j51a2-lightdm-gtk-greeter-xgreeters

  #     sessions-directory = /nix/store/9qa19mamnmkf5q6109gg3g2d3d8sn3yj-desktops/share/xsessions:/nix/store/9qa19mamnmkf5q6109gg3g2d3d8sn3yj-desktops/share/wayland-sessions

  #     [Seat:*]
  #     display-setup-script=xrandr -s 1920x1080
  #     xserver-command = /nix/store/6021yqkixw1g630cb138nnpi238w8jc7-xserver-wrapper
  #     session-wrapper = /nix/store/ic8hnkzm4zdjk9jp7gvl7ymj8kxqgwmp-xsession-wrapper
  #     greeter-session = lightdm-gtk-greeter
  # '';

}
