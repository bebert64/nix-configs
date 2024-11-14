{
  pkgs,
  home-manager,
  lib,
  config,
  specialArgs,
  ...
}:
{
  imports = [ home-manager.nixosModules.home-manager ];

  options.by-db = with lib; {
    user = {
      name = mkOption { type = types.str; };
      description = mkOption { type = types.str; };
    };
    bluetooth.enable = mkOption {
      type = types.bool;
      default = false;
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
          description = "${cfg.user.description}";
          extraGroups = [
            "networkmanager"
            "wheel"
          ];
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGJxBmEvziBiowhj2vd0fbExl4b5Dkf/5rSBjnw3iMbV romain@stockly.ai"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGjhHLih5ykkFc2kOGxVboxjnUARDNMn4/ptovfaNceC bebert64@gmail.com"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILl4CdsJeD+h9xmNfuSPSHHFz6N9pWfa0uCIYq2b1sGR romain@fixe-salon"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJoCrtZ5Gy9g7kLEhyqVyvdHIVgCq/hhZuY5ghu9GLzc bebert64@gmail.com"
          ];
        };
        defaultUserShell = pkgs.zsh;
      };

      home-manager = {
        users.${cfg.user.name} = {
          imports = [ ./home-manager.nix ];
          by-db = {
            username = "${cfg.user.name}";
            git = {
              userName = "RomainC";
              userEmail = "bebert64@gmal.com";
            };
          };
        };
        backupFileExtension = "bckp";
        extraSpecialArgs = specialArgs;
      };

      services = {
        # X11 Configuration
        xserver = {
          enable = true;
          desktopManager = {
            session = [
              {
                name = "home-manager";
                start = ''
                  ${pkgs.runtimeShell} $HOME/.hm-xsession &
                  waitPID=$!
                '';
              }
            ];
          };
          windowManager.i3.package = pkgs.i3-gaps;
          xkb = {
            layout = "fr";
            variant = "";
          };
        };
        udisks2.enable = true; # automount usb keys and drives
        gnome.gnome-keyring.enable = true; # seahorse can be used as a GTK app for this
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
        # Enable the bluetooth daemon.
        blueman.enable = cfg.bluetooth.enable;
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
      };

      nixpkgs.config.allowUnfree = true;

      hardware = {
        pulseaudio.enable = lib.mkDefault true;
        bluetooth.enable = cfg.bluetooth.enable;
      };

      # Bootloader.
      boot.loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
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

      fonts = {
        packages = with pkgs; [ dejavu_fonts ];
        fontconfig = {
          enable = true;
          defaultFonts = {
            monospace = [ "DejaVu Sans Mono" ];
            sansSerif = [ "DejaVu Sans" ];
            serif = [ "DejaVu Serif" ];
          };
        };
      };

      programs = {
        zsh = {
          enable = true;
          histSize = 200000;
          ohMyZsh.enable = true;
          autosuggestions.enable = true;
          syntaxHighlighting.enable = true;
        };
        dconf.enable = true; # Necessary for some GTK settings to get properly saved
        light.enable = true;
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

      systemd = {
        user.services.polkit-gnome-authentication-agent-1 = {
          description = "polkit-gnome-authentication-agent-1";
          wantedBy = [ "graphical-session.target" ];
          wants = [ "graphical-session.target" ];
          after = [ "graphical-session.target" ];
          serviceConfig = {
            Type = "simple";
            ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
          };
        };
      };

    };
}
