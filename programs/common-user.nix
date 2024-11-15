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
    ./direnv.nix
    ./firefox.nix
    ./git.nix
    ./rofi.nix
    ./thunderbird.nix
    ./udiskie.nix
    ./vdhcoapp.nix
    ./vim.nix
  ];

  home.packages = [ (pkgs.callPackage ./insomnia.nix { }) ];
}
