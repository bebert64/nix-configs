{
  pkgs,
  config,
  ...
}:
{
  imports = [ ./common.nix ];

  config =
    let
      cfg = config.by-db;
    in
    {
      # Bootloader.
      boot = {
        loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };
        # Used to cross-compile for the Raspberry Pi
        binfmt.emulatedSystems = [ "aarch64-linux" ];
      };

      fonts = {
        packages = [ pkgs.dejavu_fonts ];
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
        bluetooth.enable = cfg.bluetooth.enable;
      };

      home-manager = {
        users.${cfg.user.name} = {
          imports = [ ../home-manager/workstation.nix ];
          by-db = {
            bluetooth.enable = cfg.bluetooth.enable;
          };
        };
      };

      programs = {
        dconf.enable = true; # Necessary for some GTK settings to get properly saved
        light.enable = true;
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
        # Enable the bluetooth daemon.
        blueman.enable = cfg.bluetooth.enable;
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
