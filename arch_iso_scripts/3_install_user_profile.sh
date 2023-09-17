#!/usr/bin/env bash
set -euo pipefail

# install yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd
rm -rf yay

# Install user packages
yay -Syu xorg-server xorg-xinit xdg-utils fontconfig nfs-utils polkit alock udisks2

# Install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# install nix
curl --proto '=https' --tlsv1.2 -sSfL https://nixos.org/nix/install -o nix_install.sh
chmod +x ./nix_install.sh
./nix_install.sh --daemon
rm nix_install.sh

# Need to reboot for nix to load correctly
echo "you should now reboot"
