{
  pkgs,
  home-manager,
  lib,
  config,
  specialArgs,
  ...
}:
{
  imports = [
    home-manager.nixosModules.home-manager
    ../nas.nix
  ];

  options.by-db = with lib; {
    hmUser = mkOption {
      type = types.attrs;
      internal = true;
      readOnly = true;
      description = "Home Manager user config for the by-db user";
      default = config.home-manager.users.${config.by-db.user.name};
    };
    user = {
      name = mkOption { type = types.str; };
      description = mkOption { type = types.str; };
    };
    bluetooth.enable = mkEnableOption "Whether or not to activate the global bluetooth daemon";
    nix-cores = mkOption { type = types.number; };
    nix-max-jobs = mkOption { type = types.number; };
    nix-high-ram = mkOption { type = types.str; };
    nix-max-ram = mkOption { type = types.str; };
  };

  config =
    let
      byDbNixos = config.by-db;
    in
    {
      users = {
        users.${byDbNixos.user.name} = {
          isNormalUser = true;
          hashedPassword = "$y$j9T$tfVkqx8wSszbCd1IrY7eH.$ZWUxuTCMxC84rmMzpIcEl7wGkfRywng7Swn4pdqI7S5";
          description = "${byDbNixos.user.description}";
          extraGroups = [
            "networkmanager"
            "wheel"
          ];
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGjhHLih5ykkFc2kOGxVboxjnUARDNMn4/ptovfaNceC bebert64@gmail.com"
          ];
        };
        defaultUserShell = pkgs.zsh;
      };

      home-manager = {
        users.${byDbNixos.user.name} = {
          by-db = {
            user = {
              name = byDbNixos.user.name;
              description = byDbNixos.user.description;
            };
            git = {
              user = {
                name = "RomainC";
                email = "bebert64@gmail.com";
              };
            };
            bluetooth.enable = byDbNixos.bluetooth.enable;
          };
        };
        backupFileExtension = "bckp";
        extraSpecialArgs = specialArgs;
      };

      services = {
        # Enable the OpenSSH daemon.
        openssh = {
          enable = true;
          # require public key authentication for better security
          settings = {
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
            X11Forwarding = true;
          };
        };
      };

      nix = {
        # Auto perodic garbage collection
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 30d";
        };
        settings.experimental-features = [
          "nix-command"
          "flakes"
        ];
        # Keep build inputs when using garbage collection
        extraOptions = ''
          keep-outputs = true
        '';
      };

      # Set your time zone.
      time.timeZone = lib.mkDefault "Europe/Paris";

      # Configure console keymap
      console.keyMap = lib.mkDefault "fr";

      programs.zsh.enable = true;

      environment = {
        pathsToLink = [ "/libexec" ];
      };

      hardware.bluetooth.enable = byDbNixos.bluetooth.enable;

      # Select internationalisation properties.
      i18n = {
        defaultLocale = lib.mkDefault "en_US.UTF-8";

        extraLocaleSettings = lib.mkDefault {
          LC_ADDRESS = "fr_FR.UTF-8";
          LC_IDENTIFICATION = "fr_FR.UTF-8";
          LC_MEASUREMENT = "fr_FR.UTF-8";
          LC_MONETARY = "fr_FR.UTF-8";
          LC_NAME = "fr_FR.UTF-8";
          LC_NUMERIC = "fr_FR.UTF-8";
          LC_PAPER = "fr_FR.UTF-8";
          LC_TELEPHONE = "fr_FR.UTF-8";
          LC_TIME = "fr_FR.UTF-8";
        };
      };

      security = {
        polkit.enable = true;
        pam.services.lightdm.enableGnomeKeyring = true;
      };

      services = {
        earlyoom = {
          enable = true; # Enable earlyoom to kill processes when memory is low
          freeSwapThreshold = 5;
          freeMemThreshold = 5;
          extraArgs = [
            "--prefer"
            "'^(ferdium|firefox)$'"
          ];
        };
      };

      # Necessary for remote installation, using --sudo or to get access to additional caches
      nix.settings.trusted-users = [ "${byDbNixos.user.name}" ];

      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "24.05"; # Did you read the comment?
    };
}
