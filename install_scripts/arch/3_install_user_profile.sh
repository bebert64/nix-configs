#!/usr/bin/env bash
set -euo pipefail

# install yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ~
rm -rf yay

# Install user packages
yay -Syu xorg-server xorg-xinit xdg-utils fontconfig nfs-utils polkit alock udisks2 picom postgresql-libs

# Install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install video downloader companion app
cd ~
curl -L https://github.com/aclap-dev/vdhcoapp/releases/download/v2.0.10/vdhcoapp-2.0.10-linux-x86_64.tar.bz2 -o ~/net.downloadhelper.coapp-2.0.10_amd64.tar.gz
rm -rf ~/.dwhelper
mkdir ~/.dwhelper
tar xf net.downloadhelper.coapp-2.0.10_amd64.tar.gz -C ~/.dwhelper
mv -v ~/.dwhelper/vdhcoapp-2.0.10/* ~/.dwhelper
rm -r ~/.dwhelper/vdhcoapp-2.0.10
~/.dwhelper/vdhcoapp install --user
rm ~/net.downloadhelper.coapp-2.0.10_amd64.tar.gz

# install nix
cd ~
curl --proto '=https' --tlsv1.2 -sSfL https://nixos.org/nix/install -o nix_install.sh
chmod +x ./nix_install.sh
./nix_install.sh --daemon
rm nix_install.sh

# Need to reboot for nix to load correctly
echo "you should now reboot"
