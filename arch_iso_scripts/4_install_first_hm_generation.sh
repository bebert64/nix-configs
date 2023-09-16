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
cd nix-configs/home-manager && home-manager switch --flake .#$FLAKE_CONFIG_NAME --extra-experimental-features nix-command --extra-experimental-features flakes

# Needed for rofi to find apps and for all apps to find icons / cursors / etc...
sudo bash -c 'cat >> /etc/profile << EOL
if [ -f \$HOME/.nix-profile/etc/profile.d/nix.sh ];
then
     source \$HOME/.nix-profile/etc/profile.d/nix.sh
fi

export XDG_DATA_DIRS=\$HOME/.nix-profile/share:/usr/local/share:/usr/share:\$HOME/.local/share:$XDG_DATA_DIRS
EOL'

# Make zsh default shell
sudo bash -c 'echo $(which zsh) >> /etc/shells'
chsh -s $(which zsh)

# Create dir to mount NAS
sudo mkdir /mnt/NAS

# Update font's cache
fc-cache -f -v

# Done!
echo "you should now reboot"
