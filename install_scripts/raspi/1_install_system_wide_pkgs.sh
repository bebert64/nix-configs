#!/usr/bin/env bash
set -euo pipefail

# Install apt packages
sudo apt update
sudo apt upgrade
sudo apt install git apache2 qbittorrent-nox sqlite3 postgresql phppgadmin openssl nfs-common vim ffmpeg

# Clone nix-configs onto romain's home dir
cd ~
git clone https://github.com/bebert64/nix-configs

# Add NAS to fstab
sudo mkdir /mnt/NAS
sudo bash -c 'echo "nas.capucina.house:/volume1/NAS 	/mnt/NAS 	nfs 	noauto,x-systemd.automount 	0 	0" >> /etc/fstab'

# Get ipv6 generated from MAC address
sudo sed -i 's/#slaac hwaddr/slaac hwaddr/g' /etc/dhcpcd.conf
sudo sed -i 's/slaac private/# slaac private/g' /etc/dhcpcd.conf

# Set up locales
# echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# install nix
cd ~
curl --proto '=https' --tlsv1.2 -sSfL https://nixos.org/nix/install -o nix_install.sh
chmod +x ./nix_install.sh
./nix_install.sh --daemon
rm nix_install.sh

# Download stash and symlink config
cd ~
sudo curl -L https://github.com/stashapp/stash/releases/download/v0.22.1/stash-linux-arm64v8 -o /usr/local/bin/stash-linux-arm64v8
sudo chmod +x /usr/local/bin/stash-linux-arm64v8
sudo mkdir /usr/local/etc/stash
sudo ln -s ~/nix-configs/dotfiles/stash/config.yml /usr/local/etc/stash/
sudo ln -s ~/nix-configs/dotfiles/stash/scrapers /usr/local/etc/stash/

# Symlink rc.local (to auto start packages at boot)
sudo rm /etc/rc.local
sudo ln -s ~/nix-configs/dotfiles/raspi/rc.local /etc/

# Update postgres config
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/13/main/postgresql.conf 
sudo sed -i "s=127.0.0.1/32=192.168.1.0/24=g" /etc/postgresql/13/main/pg_hba.conf 

# Need to reboot for nix to load correctly
echo "you should now reboot"
