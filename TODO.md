## raspi
# Install script
copy apache config
qtorrent config (+ certificate?)
config phppgadmin (file to copy in /etc/apache2)
restore postgres
restore (or install new?) certificates
    capucina
    raspi.capucina
Try to get wildcard validation for certificate
# Backup
automate regular save of postgres + stash_db content to NAS
    curl http call to launch db backup for stash
    add line to cheatsheet on how to restore
# Create image
once everything is validated, install clean and create image

## General
migrate back to chrome
    check if possible launching specific profile from cli
    check if possible to not "see" other profiles too easily
    check extensions
    then move bookmarks
get all data from laptop to NAS
Solve datagrip password problem (plugin null)
Shortcut to open 1password
# Freebox / html
Freebox is not currently accessible from outside LAN
Html page at domain root, with links to different apps
backup freebox config

# Various (harder) improvements
from autorandr --force machin to something in nix config
fix mount-NAS (make it depend from host-specific)
finish ranger config with displaying previews for various files
finish conky configs
add ENV variable for firefox_db (host-specifics ?)
locale for raspberry
fix yay changing keyboard config (add setxkbmap at the end ?)
lock numpad at boot

# Clean-up (not really needed, but sill good)
clean polybar config
test which fonts can be downloaded from nix (to reduce repo size)



## Stash
Finish inserting missing titles and replace current db

## Coding
Chrome bookmarks SDK (read only)
Nas SDK
    Is NAS mounted
    Is NAS accessible?
    Try Mount NAS
Backup SDK?
Stash_app_sdk
Move all libs into one repo/workspace
    keep projects separated
    cargo toml with path to libs while in dev
    replace with github link to specific version if archiving (write exact syntax somewhere for reference)
