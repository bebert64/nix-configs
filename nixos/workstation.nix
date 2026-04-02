{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./common.nix
    ../programs/auto-update
    ../programs/generative-ai
  ];

  options.byDb = {
    generativeAi.enable = lib.mkEnableOption "Whether to install generative AI tools";
  };

  config =
    let
      nixosBydbConfig = config.byDb;
    in
    {
      boot = {
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
        etc."direnv/direnv.toml".text = ''
          [global]
          hide_env_diff = true
        '';
        sessionVariables = {
          NIXOS_OZONE_WL = "1";
          MOZ_ENABLE_WAYLAND = "1";
          QT_QPA_PLATFORM = "wayland";
          SDL_VIDEODRIVER = "wayland";
          XDG_SESSION_TYPE = "wayland";
          XDG_CURRENT_DESKTOP = "sway";
        };
      };

      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
          if ((action.id.indexOf("org.freedesktop.login1.suspend") === 0 ||
               action.id.indexOf("org.freedesktop.login1.inhibit") === 0) &&
              subject.isInGroup("users")) {
            return polkit.Result.YES;
          }
        });
      '';

      programs = {
        dconf.enable = true;
        light.enable = true;
        nix-ld.enable = true;
        sway = {
          enable = true;
          package = pkgs.swayfx;
          wrapperFeatures.gtk = true;
        };
      };

      services = {
        xserver.xkb = {
          layout = "fr";
          variant = "";
        };
        udisks2.enable = true;
        gnome.gnome-keyring.enable = true;
        blueman.enable = nixosBydbConfig.bluetooth.enable;
      };

      xdg.portal = {
        enable = true;
        wlr.enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
        config.common.default = "*";
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
