## raspi
# Install script
copy apache config
restore postgres
restore (or install new?) certificates
    capucina
    raspi.capucina
# Backup
automate regular save of postgres + stash_db content to NAS
    add line to cheatsheet on how to restore

## General
get all data from laptop to NAS
# Freebox / html
Html page at domain root, with links to different apps
backup freebox config

# Various (harder) improvements
fix mount-NAS (make it depend from host-specific)
finish ranger config with displaying previews for various files
finish conky configs
add ENV variable for firefox_db (host-specifics ?)

# Clean-up (not really needed, but sill good)
clean polybar config
test which fonts can be downloaded from nix (to reduce repo size)
