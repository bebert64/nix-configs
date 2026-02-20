{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./common.nix
    ../programs/generative-ai
  ];

  options.byDb = {
    generativeAi.enable = lib.mkEnableOption "Whether to install generative AI tools";
  };

  config =
    let
      nixosBydbConfig = config.byDb;
      homeDir = nixosBydbConfig.hmUser.home.homeDirectory;
    in
    {
      # Bootloader.
      boot = {
        # Used to cross-compile for the Raspberry Pi
        binfmt.emulatedSystems = [ "aarch64-linux" ];
      };

      fonts = {
        packages = [
          pkgs.dejavu_fonts
          pkgs.nerd-fonts.fira-code
          pkgs.nerd-fonts.iosevka
        ];
        fontconfig = {
          enable = true;
          defaultFonts = {
            monospace = [ "DejaVu Sans Mono" ];
            sansSerif = [ "DejaVu Sans" ];
            serif = [ "DejaVu Serif" ];
          };
        };
      };

      hardware = {
        bluetooth.enable = nixosBydbConfig.bluetooth.enable;
      };

      home-manager = {
        users.${nixosBydbConfig.user.name} = {
          imports = [ ../home-manager/workstation.nix ];
        };
      };

      nix.settings = {
        cores = nixosBydbConfig.nixCores;
        max-jobs = nixosBydbConfig.nixMaxJobs;
      };

      environment = {
        # Hide direnv diff when entering a directory
        etc."direnv/direnv.toml".text = ''
          [global]
          hide_env_diff = true
        '';
      };

      programs = {
        dconf.enable = true; # Necessary for some GTK settings to get properly saved
        light.enable = true;
        nix-ld.enable = true; # Necessary for rust-analyzer to function in cursor
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
                  ${pkgs.runtimeShell} ${homeDir}/.hm-xsession &
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
        # Enable the bluetooth daemon.
        blueman.enable = nixosBydbConfig.bluetooth.enable;
      };

      systemd = {
        services.nix-daemon.serviceConfig = {
          MemoryHigh = nixosBydbConfig.nixHighRam;
          MemoryMax = nixosBydbConfig.nixMaxRam;
        };

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
