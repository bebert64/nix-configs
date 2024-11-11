{
  pkgs,
  home-manager,
  host-specific,
  ...
}:
{
  imports = [ home-manager.nixosModules.home-manager ];

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
      xkb = {
        layout = "fr";
        variant = "";
      };
    };
    udisks2.enable = true; # automount usb keys and drives
    usbmuxd = {
      # used to mount Ipad
      enable = true;
      package = pkgs.usbmuxd2;
    };
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
  };
  users.defaultUserShell = pkgs.zsh;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

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

  #   networking.extraHosts = ''
  #    127.0.0.1 mafreebox.freebox.fr
  #  '';

  # Auto perodic garbage collection
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Enable the bluetooth daemon.
  services.blueman.enable = (host-specific.bluetooth or false);
  hardware.bluetooth.enable = (host-specific.bluetooth or false);

}
