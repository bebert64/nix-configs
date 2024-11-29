{ pkgs, ... }:
{
  imports = [
    ./common.nix
    ./configs/conky
    ./configs/datagrip
    ./configs/picom
    ./configs/polybar
    ./configs/qt
    ./configs/music
    ./configs/terminal
    ./configs/vscode
    ./configs/autorandr.nix
    ./configs/avidemux.nix
    ./configs/calculator.nix
    ./configs/email.nix
    ./configs/firefox.nix
    ./configs/i3.nix
    ./configs/lock.nix
    ./configs/rofi.nix
    ./configs/slack.nix
    ./configs/udiskie.nix
    ./configs/vdhcoapp.nix
  ];

  home.packages = [ (pkgs.callPackage ./configs/insomnia.nix { }) ];
}
