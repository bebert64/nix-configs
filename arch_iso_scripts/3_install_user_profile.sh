#!/usr/bin/env bash
set -euo pipefail

# Check if running in sudo
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# install yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd
rm -rf yay

# Install user packages
yay -Syu xorg-server xorg-xinit xdg-utils fontconfig nfs-utils polkit alock

# Install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# install nix
curl --proto '=https' --tlsv1.2 -sSfL https://nixos.org/nix/install -o nix-install.sh
chmod +x ./nix-install.sh
./nix_install.sh --daemon
rm nix_install.sh

# Need to reboot for nix to load correctly
echo "you should now reboot"
