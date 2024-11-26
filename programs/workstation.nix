{ pkgs, ... }:
{
  imports = [
    ./common.nix
    ./conky
    ./datagrip
    ./picom
    ./polybar
    ./qt
    ./music
    ./terminal
    ./vscode
    ./autorandr.nix
    ./avidemux.nix
    ./calculator.nix
    ./email.nix
    ./firefox.nix
    ./i3.nix
    ./lock.nix
    ./rofi.nix
    ./slack.nix
    ./udiskie.nix
    ./vdhcoapp.nix
  ];

  home.packages = [ (pkgs.callPackage ./insomnia.nix { }) (pkgs.callPackage ./ffsync.nix { }) ];
}
