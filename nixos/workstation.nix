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

      nix.settings = {
        cores = cfg.nix-cores;
        max-jobs = cfg.nix-max-jobs;
      };

      programs = {
        dconf.enable = true; # Necessary for some GTK settings to get properly saved
        light.enable = true;
      };

      security.pam.services.sshd.text = pkgs.lib.mkDefault (
        pkgs.lib.mkAfter ''
          session     optional    pam_exec.so ${pkgs.writeScriptBin "sleep-on-ssh-logout" ''
            #!/usr/bin/env bash
            if [ "$PAM_TYPE" = "close_session" ] && [[ -z $(who -a | grep pts | grep "(") ]]; then
              # systemctl suspend
            fi
          ''}/bin/sleep-on-ssh-logout
        ''
      );

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
        services.nix-daemon.serviceConfig = {
          MemoryHigh = "7G";
          MemoryMax = "8G";
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
