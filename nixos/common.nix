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
    user = {
      name = mkOption { type = types.str; };
      description = mkOption { type = types.str; };
    };
  };

  config =
    let
      cfg = config.by-db;
    in
    {
      users = {
        users.${cfg.user.name} = {
          isNormalUser = true;
          hashedPassword = "$y$j9T$tfVkqx8wSszbCd1IrY7eH.$ZWUxuTCMxC84rmMzpIcEl7wGkfRywng7Swn4pdqI7S5";
          description = "${cfg.user.description}";
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
        users.${cfg.user.name} = {
          by-db = {
            username = "${cfg.user.name}";
            git = {
              userName = "RomainC";
              userEmail = "bebert64@gmail.com";
            };
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

      # Select internationalisation properties.
      i18n = {
        defaultLocale = lib.mkDefault "en_US.utf8";

        extraLocaleSettings = lib.mkDefault {
          LC_ADDRESS = "fr_FR.utf8";
          LC_IDENTIFICATION = "fr_FR.utf8";
          LC_MEASUREMENT = "fr_FR.utf8";
          LC_MONETARY = "fr_FR.utf8";
          LC_NAME = "fr_FR.utf8";
          LC_NUMERIC = "fr_FR.utf8";
          LC_PAPER = "fr_FR.utf8";
          LC_TELEPHONE = "fr_FR.utf8";
          LC_TIME = "fr_FR.utf8";
        };
      };

      # Configure console keymap
      console.keyMap = lib.mkDefault "fr";

      programs = {
        zsh = {
          enable = true;
          histSize = 200000;
          ohMyZsh.enable = true;
          autosuggestions.enable = true;
          syntaxHighlighting.enable = true;
        };
      };

      # List packages installed in system profile. To search, run:
      # $ nix search wget
      environment = {
        systemPackages = with pkgs; [
          # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
          (vim_configurable.customize {
            name = "vim";
            vimrcConfig.packages.myplugins = with vimPlugins; {
              start = [ vim-nix ];
            };
          })
          git
          ntfs3g
          wget
        ];
        pathsToLink = [ "/libexec" ];
      };

      security = {
        polkit.enable = true;
        pam.services.lightdm.enableGnomeKeyring = true;
      };

      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "24.05"; # Did you read the comment?
    };
}
