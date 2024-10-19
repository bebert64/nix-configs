#!/usr/bin/env bash
set -euo pipefail

# Setup Stockly
cd ~
mkdir -p Stockly
cd Stockly 
git clone git@github.com:Stockly/Main.git
cd Main
git config --local core.hooksPath ./dev_tools/git_hooks/

# Install wallpapers-manager and sync wallpapers
cd ~
mkdir -p code
cd code
git clone git@github.com:bebert64/wallpapers-manager
cd wallpapers-manager
cargo build --release
chmod +x target/release/wallpapers-manager
sudo cp target/release/wallpapers-manager /usr/local/bin

sync-wallpapers

# Run add-radios to Strawberry
cd ~/code
git clone git@github.com:bebert64/strawberry-add-playlist.git
cd strawberry-add-playlist
cargo run -- -c radios.json
