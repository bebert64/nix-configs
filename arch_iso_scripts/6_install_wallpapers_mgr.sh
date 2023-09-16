#!/usr/bin/env bash
set -euo pipefail

cd
mkdir code
cd code
git clone git@github.com:bebert64/wallpapers-mgr
cd wallpapers-mgr
cargo build --release
cp target/release/wallpapers-mgr $HOME/
