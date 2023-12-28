#!/usr/bin/env bash
set -euo pipefail

certbot renew

# Copy to stash
cp /etc/letsencrypt/live/capucina.house/privkey.pem /usr/local/etc/stash/stash.key
cp /etc/letsencrypt/live/capucina.house/cert.pem /usr/local/etc/stash/stash.cert

# Copy to freebox

# Copy to synology
