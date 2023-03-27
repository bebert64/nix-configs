host-specific: { pkgs, lib, ... }@inputs:

let
  monoFont = "DejaVu Sans Mono";
  args = ({ inherit monoFont; } // inputs);
in
{
  
  # Packages Home-Manager doesn't have specific handling for
  home.packages = with pkgs; [
    gnome.gnome-terminal
    dconf
    btop
    sshfs
    ranger
    arandr # GUI to configure screens positions (need to kill autorandr)
    vlc
    rofi
    feh
    polkit
    polkit_gnome
  ];


  # Programs known by Home-Manager
  programs = {
    git = import ./programs/git.nix;
  };

  # X Config
  xsession = {
    enable = true;
    scriptPath = ".hm-xsession";
    windowManager.i3 = import ./programs/i3.nix (args// { host-specific = host-specific.i3 args; });
    numlock.enable = true;
  };
  gtk = {
    enable = true;
    theme = {
      package = pkgs.gnome.gnome-themes-extra;
      name = "Adwaita-dark";
    };
  };

  # systemd = {
  #   user.services.polkit-gnome-authentication-agent-1 = {
  #     # description = "polkit-gnome-authentication-agent-1";
  #     # wantedBy = [ "graphical-session.target" ];
  #     # wants = [ "graphical-session.target" ];
  #     # after = [ "graphical-session.target" ];  
  #     enable = true;
  #     serviceConfig = {
  #         Type = "simple";
  #         ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
  #         Restart = "on-failure";
  #         RestartSec = 1;
  #         TimeoutStopSec = 10;
  #       };
  #   };
  # };

  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true; # Necessary for vscode
  home.stateVersion = "22.05";
}
