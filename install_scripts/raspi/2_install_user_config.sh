#!/usr/bin/env bash
set -euo pipefail

# Setup nix
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install

# Ask config name and install it
cd ~/nix-configs/home-manager
home-manager switch --flake .#$raspi --extra-experimental-features nix-command --extra-experimental-features flakes
