# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

# This configuration file is not part of the default system, instead it is used to factor
# configurations on my different computers together

{ config, pkgs, flake-inputs, host-specific, ... }:

{
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
    packages = [ pkgs.firefox pkgs.vscode pkgs.ranger ];
  };
  home-manager.users.romain = import ./home.nix host-specific;
  
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
      noto-fonts
      noto-fonts-emoji
      dejavu_fonts
      liberation_ttf
      powerline-fonts
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

  programs.zsh.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  users.mutableUsers = true;

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

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
}
