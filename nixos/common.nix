{ config, pkgs, flake-inputs, host-specific, ... }:

{
    imports = [  flake-inputs.home-manager.nixosModules.home-manager ];

  # X11 Configuration
  services.xserver = {  
    enable = true;
    desktopManager.session = [{
      name = "home-manager";
      start = ''
        ${pkgs.runtimeShell} $HOME/.hm-xsession &
        waitPID=$!
      '';
    }];

    xkb = { layout = "fr"; variant = ""; }; 
    # xkbOptions = "caps:swapescape";
  };

  services = {
    udisks2.enable = true;  # automount usb keys and drives
    usbmuxd = {  # used to mount Ipad
      enable = true;
      package = pkgs.usbmuxd2;
    };
    gnome.gnome-keyring.enable = true; # seahorse can be used as a GTK app for this
    # Enable the OpenSSH daemon.
    openssh.enable = true;
    displayManager.autoLogin = { enable = true; user = "romain"; };
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
  
  fonts = {
    packages = with pkgs; [
      fira-code
      noto-fonts
      noto-fonts-emoji
      dejavu_fonts
      liberation_ttf_v1
      powerline-fonts
      font-awesome_4
      font-awesome_5
      font-awesome
      nerdfonts
    ];
    fontconfig.enable = true;
    fontconfig.defaultFonts = {
      monospace = [
        "DejaVu Sans Mono"
        "Noto mono"
      ];
      sansSerif = [
        "DejaVu Sans"
        "Noto Sans"
      ];
      serif = [
        "Liberation Serif"
        "DejaVu Serif"
        "Noto Serif"
      ];
    };
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  programs = {
    zsh = {
      enable = true;
      histSize = 200000;
      ohMyZsh = {
        enable = true;
      };
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
    };
    dconf.enable = true; # Necessary for some GTK settings to get properly saved
    light.enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    git
    ntfs3g
    wget
  ];
  environment.pathsToLink = ["/libexec"];

  security.polkit.enable = true;
  security.pam.services.lightdm.enableGnomeKeyring = true;
  
#   networking.extraHosts = ''
#    127.0.0.1 mafreebox.freebox.fr
#  '';

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable the bluetooth daemon.
  services.blueman.enable = host-specific.bluetooth;
  hardware.bluetooth.enable = host-specific.bluetooth;

}
