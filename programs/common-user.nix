{ pkgs, ... }:
{
  imports = [
    ./conky
    ./datagrip
    ./i3
    ./picom
    ./polybar
    ./qt
    ./ranger
    ./ssh
    ./strawberry
    ./tilix
    ./vscode
    ./zsh
    ./alock.nix
    ./autorandr.nix
    ./btop.nix
    ./firefox.nix
    ./git.nix
    ./rofi.nix
    ./thunderbird.nix
    ./udiskie.nix
    ./vdhcoapp.nix
  ];

  home.packages = [ (pkgs.callPackage ./insomnia.nix { }) ];
}
