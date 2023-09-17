#!/usr/bin/env bash
set -euo pipefail

cd ~
mkdir -p code
cd code
git clone git@github.com:bebert64/wallpapers-mgr
cd wallpapers-mgr
cargo build --release
chmod +x target/release/wallpapers-mgr
sudo cp target/release/wallpapers-mgr /usr/local/bin

mount nas.capucina.house:/volume1/NAS
cp ~/mnt/NAS/Wallpapers ~
