{ pkgs, ... }:
{
  imports = [
    ./conky
    ./datagrip
    ./picom
    ./polybar
    ./qt
    ./ranger
    ./rofi
    ./secrets
    ./ssh
    ./music
    ./terminal
    ./vscode
    ./zsh
    ./autorandr.nix
    ./avidemux.nix
    ./btop.nix
    ./calculator.nix
    ./direnv.nix
    ./email.nix
    ./firefox.nix
    ./git.nix
    ./i3.nix
    ./lock.nix
    ./slack.nix
    ./udiskie.nix
    ./vdhcoapp.nix
    ./vim.nix
  ];

  home.packages = [ (pkgs.callPackage ./insomnia.nix { }) ];
}
