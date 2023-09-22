Clean up boot and boot sequence


## Raspy

# Backup raspy
Add howto to cheat sheet on certbot
backup apache config to dotfiles
    /etc/apache2
    add line on cheatsheet on where it needs to be symlinked (not possible through activation scripts)
automate regular save of postgres content to NAS + stash_db + stash
    https://www.tecmint.com/backup-and-restore-postgresql-database/
    add line to cheatsheet on how to restore

# Various (harder) improvements
add qbittorrent to raspberry with launch at startup

# Install script
Check which apps need to be installed via apt-get
Symlink apache config
certbot for new certificates
Check how to launch apps at startup
    https://raspberrytips.com/autostart-a-program-on-boot/
    stash
    qbittorrent
    add howto to CheatSheet

# Clean install !!


## General
get all data from laptop to NAS
format and get back space from nixos partition on fixe-bureau

# Fix ipv6 access from outside
"A Record" with freebox ipv4 88.160.246.99
"URL Redirect" all subdomain to there
Port redirect as needed (probably 5 redirection needed, i.e. all of A record + url redirect, except freebox itself)
Html page at domain root, with links to different apps
backup freebox config

# Various (easy) improvements
check if zip needed in addition to unzip and unrar
create symlink in activation rather than home.file for most cases
reorganize dotfiles in repo

# Various (harder) improvements
fix mount-NAS (make it depend from host-specific)
finish ranger config with displaying previews for various files
finish conky configs
add ENV variable for firefox_db (host-specifics ?)
re add radio + rofi menu to launch them so strawberry

# Clean-up (not really needed, but sill good)
clean polybar config
test which fonts can be downloaded from nix (to reduce repo size)
