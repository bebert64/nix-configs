# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

# This configuration file is not part of the default system, instead it is used to factor
# configurations on my different computers together

{ config, pkgs, flake-inputs, host-specific, ... }:

let
  neuropol = pkgs.callPackage ./fonts/neuropol.nix { };
in {
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.nixPath = [ "nixpkgs=${flake-inputs.nixpkgs.outPath}" ];

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure console keymap
  console.keyMap = "fr";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.defaultUserShell = pkgs.zsh;
  users.users.romain = {
    isNormalUser = true;
    description = "romain";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };
  home-manager.users.romain = import ./home.nix host-specific;
  users.mutableUsers = true;
  
  nixpkgs.config.allowUnfree = true;

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
    displayManager.autoLogin = { enable = true; user = "romain"; };

    layout = "fr";
    xkbVariant = "";
    # xkbOptions = "caps:swapescape";
  };

  services.udisks2.enable = true; # automount usb keys and drives

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
    fonts = with pkgs; [
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
        plugins = [ "git" ];
        theme = "stockly";
      };
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
    };
    dconf.enable = true; # Necessary for some GTK settings to get properly saved
    light.enable = true;
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    git
    ntfs3g
  ];
  environment.pathsToLink = ["/libexec"];

  security.polkit.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  services.gnome.gnome-keyring.enable = true; # seahorse can be used as a GTK app for this
  security.pam.services.lightdm.enableGnomeKeyring = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable the bluetooth daemon.
  services.blueman.enable = host-specific.bluetooth;
  hardware.bluetooth.enable = host-specific.bluetooth;
}
