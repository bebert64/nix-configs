#!/usr/bin/env bash
set -euo pipefail

# Setup nix
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install

# Ask config name and install it
read -p 'Name of your flake config :' FLAKE_CONFIG_NAME
cd ~
git clone https://github.com/bebert64/nix-configs
cd nix-configs/home-manager
home-manager switch --flake .#$FLAKE_CONFIG_NAME --extra-experimental-features nix-command --extra-experimental-features flakes

# Make zsh default shell
sudo bash -c 'echo $(which zsh) >> /etc/shells'
chsh -s $(which zsh)

# Create dir to mount NAS
sudo mkdir /mnt/NAS

# Update font's cache
fc-cache -f -v

# Done!
echo "you should now reboot"
