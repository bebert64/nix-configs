#!/usr/bin/env bash
set -euo pipefail

read -p 'flake-config name: ' FLAKE_CONFIG_NAME

# install yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd
rm -rf yay

yay xorg-server xorg-xinit

# install nix
curl --proto '=https' --tlsv1.2 -sSfL https://nixos.org/nix/install -o nix-install.sh
chmod +x ./nix-install.sh
./nix_install.sh --daemon

echo "you should now reboot"
