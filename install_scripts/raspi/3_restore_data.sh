#!/usr/bin/env bash
set -euo pipefail

# Restore stash from nas backup
sudo pkill stash || true
sudo rm -f /usr/local/etc/stash/stash-go.sqlite
sudo rsync -avh /mnt/NAS/Comics/Fini/Planet\ of\ the\ Apes/14\ Planet\ of\ the\ Apes\ issues/Elseworlds/stash_bkp/ /usr/local/etc/stash
sudo stash-linux-arm64v8 --nobrowser --config /usr/local/etc/stash/config.yml &

# Restore postgres data
