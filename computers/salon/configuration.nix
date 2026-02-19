{
  config,
  home-manager,
  vscode-server,
  ...
}:
let
  user = config.byDb.user;
  homeDirectory = config.users.users.${user.name}.home;
in
{
  imports = [
    ../../nixos/workstation.nix
    ./hardware-configuration.nix
    vscode-server.nixosModules.default
  ];

  byDb = {
    user = {
      name = "romain";
      description = "Romain";
    };
    nixCores = 4;
    nixMaxJobs = 2;
    nixHighRam = "22G";
    nixMaxRam = "24G";
    generativeAi.enable = true;
  };

  home-manager.users.${user.name} = {
    byDb = {
      minutesFromLockToSleep = 17;
      lockPasswordHash = "8ed81afeb2548b8488ed7874ec5ecfe692c4ee1ed38ffbbc6bee939a325a6e0b";
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
    displayManager.autoLogin = {
      enable = true;
      user = "romain";
    };
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

  nixpkgs.config.allowUnfree = true;
}
