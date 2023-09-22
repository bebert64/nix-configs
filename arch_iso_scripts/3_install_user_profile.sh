#!/usr/bin/env bash
set -euo pipefail

# install yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ~
rm -rf yay

# Install user packages
yay -Syu xorg-server xorg-xinit xdg-utils fontconfig nfs-utils polkit alock udisks2

# Install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install video downloader companion app
cd ~
curl -L https://github.com/mi-g/vdhcoapp/releases/download/v1.6.3/net.downloadhelper.coapp-1.6.3-1_amd64.tar.gz -o ~/net.downloadhelper.coapp-1.6.3-1_amd64.tar.gz
mkdir ~/.dwhelper
tar xf net.downloadhelper.coapp-1.6.3-1_amd64.tar.gz -C ~/.dwhelper
mv -v ~/.dwhelper/net.downloadhelper.coapp-1.6.3/* ~/.dwhelper
rm -r ~/.dwhelper/net.downloadhelper.coapp-1.6.3
~/.dwhelper/bin/net.downloadhelper.coapp-linux-64 install --user
rm ~/net.downloadhelper.coapp-1.6.3-1_amd64.tar.gz

# install nix
cd ~
curl --proto '=https' --tlsv1.2 -sSfL https://nixos.org/nix/install -o nix_install.sh
chmod +x ./nix_install.sh
./nix_install.sh --daemon
rm nix_install.sh

# Need to reboot for nix to load correctly
echo "you should now reboot"
