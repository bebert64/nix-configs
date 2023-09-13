## Arch + Home-Manager

# Various (easy) improvements
add ssh config to files being symlinked
check size and see if datagrip profile can be added to git repo
add .xinitrc to config (with one line "exec i3")

# Various (harder) improvements
check if polkit from home-manager can work
check if polkit_gnome is needed
check if installing firefox through yay solves default profile
    if ok, remove -P ... from i3 commands and from doc in cheat sheet
add parts about Thunderbird profile to CheatSheet

# i3 commands do execute at startup
Fix udiskie

# Install script
transform yay apps into real script

# Clean install !!


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

# Fix ipv6 access from outside
"A Record" with freebox ipv4 88.160.246.99
"URL Redirect" all subdomain to there
Port redirect as needed (probably 5 redirection needed, i.e. all of A record + url redirect, except freebox itself)
Html page at domain root, with links to different apps
backup freebox config

# Various (easy) improvements
add loading btop config to activation script
check if zip needed in addition to unzip and unrar
add i3 command + keybinding for calculator
i3 config : open apps in specific workspace, except for firefox
rename dirs in home, with lowercase names (mnt / wallpapers / code / etc...)
do not mkdir for cluster (better to ssh and ranger directly)
remove mount point for charybdis and add how-to to cheat sheet instead
create symlink in activation rather than home.file for most cases

# Various (harder) improvements
Fix caffeine icon + hicolor theme
fix mount-NAS (make it depend from host-specific)
mod + i in i3 only shows one empty desktop
finish ranger config with displaying previews for various files
finish conky configs
add ENV variable for firefox_db (host-specifics ?)

# Clean-up (not really needed, but sill good)
clean polybar config
fix fonts in polybar
check if "rm and then recreate /mnt/usb" is needed (and rename it usb)

# Install script
add wallpapers-mgr to install script (git clone / build-release / move bin to appropriate location / clean-up)
