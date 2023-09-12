# Finish config raspy
add stash configs and param to Home-Manager raspy config (including all scrappers)

# Backup raspy
backup certificate and whole letsencrypt config to NAS
    /etc/letsencrypt
    add line on cheatsheet on where it needs to be cp
backup apache config
    /etc/apache2
    add line on cheatsheet on where it needs to be cp
backup postgresql general config
    add line on cheatsheet on how to restore
automate regular save of postgres content to NAS + stash_db + stash
    add line to cheatsheet on how to restore
Add howto to cheat sheet on certbot

# Fix ipv6 access from outside
"A Record" with freebox ipv4 88.160.246.99
"URL Redirect" all subdomain to there
Port redirect as needed (probably 5 redirection needed, i.e. all of A record + url redirect, except freebox itself)
Html page at domain root, with links to different apps

# Various (easy) improvements
finish ranger activation script for bookmarks (sed... command available in arch fixe-bureau zsh history)
add loading btop config to activation script
check if zip needed in addition to unzip and unrar
add i3 command + keybinding for calculator
i3 config : open apps in specific workspace, except for firefox
rename dirs in home, with lowercase names (mnt / wallpapers / code / etc...)
do not mkdir for cluster (better to ssh and ranger directly)
remove mount point for charybdis and add how-to to cheat sheet instead
create symlink in activation rather than home.file for most cases
add ssh config to files being symlinked
check size and see if datagrip profile can be added to git repo
add .xinitrc to config (with one line "exec i3")

# Various (harder) improvements
fix mount-NAS (make it depend from host-specific)
mod + i in i3 only shows one empty desktop
add qbittorrent to raspberry with launch at startup
finish ranger config with displaying previews for various files
finish conky configs
check if polkit from home-manager can work
check if polkit_gnome is needed
add ENV variable for firefox_db (host-specifics ?)

# i3 commands do execute at startup
Fix caffeine icon + hicolor theme
Fix udiskie

# Clean-up (not really needed, but sill good)
clean polybar config
fix fonts in polybar
check if "rm and then recreate /mnt/usb" is needed (and rename it usb)

# Install script
get all data from laptop to NAS
transform yay apps into real script
add wallpapers-mgr to install script (git clone / build-release / move bin to appropriate location / clean-up)
clean install for everything !!

# Last, not really needed
check if installing firefox and thunderbird through yay solves default profile
    if ok, remove -P ... from i3 commands and from doc in cheat sheet
