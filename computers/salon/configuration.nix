{
  config,
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
  };

  services.vscode-server = {
    enable = true;
    installPath = [
      "$HOME/.vscode-server"
      "$HOME/.vscode-server-oss"
      "$HOME/.vscode-server-insiders"
      "$HOME/.cursor-server"
    ];
  };

  # systemd.tmpfiles.settings =
  # let
  #   createFile = (
  #     { path, file }:
  #      {
  #       # Create the directory so that it has the appropriate permissions if it doesn't already exist
  #       # Otherwise the directive below creating the symlink would have that owned by root
  #       name = "${homeDirectory}/${path}";
  #       value = file user.name;
  #     }
  #   );
  #   # homeDirectory = (
  #   #   path:
  #   #   createFile {
  #   #     inherit path;
  #   #     file = (
  #   #       username: {
  #   #         "d" = {
  #   #           user = username;
  #   #           group = "users";
  #   #           mode = "0755";
  #   #         };
  #   #       }
  #   #     );
  #   #   }
  #   # );
  # in
  # {
  #   # We need to create each of the folders before the next file otherwise parents get owned by root
  #   # "80-setup-config-folder-for-all-users" = homeDirectory ".config";
  #   # "81-setup-systemd-folder-for-all-users" = homeDirectory ".config/systemd";
  #   # "82-setup-systemd-user-folder-for-all-users" = homeDirectory ".config/systemd/user";
  #   "83-enable-auto-fix-vscode-server-service-for-all-users" = createFile {
  #     path = ".config/systemd/user/auto-fix-vscode-server.service";
  #     file = (
  #       username: {
  #         "L+" = {
  #           user = username;
  #           group = "users";
  #           # This path is made available by `services.vscode-server.enable = true;`
  #           argument = "/run/current-system/etc/systemd/user/auto-fix-vscode-server.service";
  #         };
  #       }
  #     );
  #   };
  # };

  networking = {
    hostName = "salon";
    interfaces.enp12s0.wakeOnLan.enable = true;
  };
}
