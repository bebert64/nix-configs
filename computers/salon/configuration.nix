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
      minutes-from-lock-to-sleep = 17;
      screens = {
        primary = "HDMI-0";
      };
      isHeadphonesOnCommand = "pactl get-default-sink | grep alsa_output.pci-0000_00_1b.0.analog-stereo";
      setHeadphonesCommand = "set-default-sink alsa_output.pci-0000_00_1b.0.analog-stereo";
      setSpeakerCommand = "set-default-sink alsa_output.pci-0000_01_00.1.hdmi-stereo-extra2";
      generativeAi.enable = true;
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
}
