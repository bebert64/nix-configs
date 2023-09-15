#!/usr/bin/env bash
set -euo pipefail

# Setup nix
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install

cd ~
git clone https://github.com/bebert64/nix-configs
cd nix-configs/home-manager && home-manager build --flake .#$FLAKE_CONFIG_NAME --extra-experimental-features nix-command --extra-experimental-features flakes

echo "you should now reboot"
