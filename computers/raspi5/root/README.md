# Configuration Files for Non-NixOS Machine

This directory contains configuration files extracted from the raspi profile, excluding nginx.

## Installation Instructions

### 1. System Packages
Install the packages listed in `../programs.txt` using your system's package manager.

### 2. User Configuration Files
All user configuration files are in `home/romain/`. Copy them to the appropriate locations:

```bash
# Copy all user config files
sudo cp -r home/romain/.config/* /home/romain/.config/
sudo cp -r home/romain/.local/* /home/romain/.local/
sudo cp -r home/romain/.ssh/* /home/romain/.ssh/
sudo cp -r home/romain/.oh-my-zsh/* /home/romain/.oh-my-zsh/
sudo cp home/romain/.zshrc /home/romain/.zshrc

# Set proper ownership
sudo chown -R romain:romain /home/romain/.config
sudo chown -R romain:romain /home/romain/.local
sudo chown -R romain:romain /home/romain/.ssh
sudo chown -R romain:romain /home/romain/.oh-my-zsh
sudo chown romain:romain /home/romain/.zshrc
```

### 3. System Configuration Files

#### Direnv
```bash
sudo cp etc/direnv/direnv.toml /etc/direnv/direnv.toml
```

### 4. System Services Configuration

#### DNSmasq
Create `/etc/dnsmasq.conf` with:
```
address=/.capucina.net/192.168.1.2
listen-address=127.0.0.1,192.168.1.2
```

#### PostgreSQL
Configure PostgreSQL authentication in `/etc/postgresql/*/main/pg_hba.conf`:
```
#type database  DBuser  auth-method
local all       all     trust
host  all       all     192.168.1.0/24  trust
host  all       all     127.0.0.1/32  trust
```

### 5. User Systemd Services

Enable and start the user services:
```bash
systemctl --user enable guitar.service
systemctl --user enable media.service
systemctl --user enable stash.service
systemctl --user enable qbittorrent.service

systemctl --user start guitar.service
systemctl --user start media.service
systemctl --user start stash.service
systemctl --user start qbittorrent.service
```

### 6. Enable User Linger
To allow user services to start at boot:
```bash
sudo loginctl enable-linger romain
```

### 7. Firewall Configuration
Open the following ports:
- 8080 (qbittorrent)
- 9999 (stash)
- 5432 (postgresql)
- 53 (dnsmasq)
- 8096 (jellyfin guitar)
- 8097 (jellyfin media)

### 8. Additional Setup

#### Jellyfin
Jellyfin will create its own config directories on first run:
- `/home/romain/.config/guitar/`
- `/home/romain/.config/media/`
- `/home/romain/.local/share/guitar/`
- `/home/romain/.local/share/media/`

#### Stash
Create the stash config directory and file:
```bash
mkdir -p /home/romain/.stash
# Create /home/romain/.stash/config.yml with your stash configuration
# Copy scrapers directory if needed
```

#### qBittorrent
The qBittorrent config is already in place. Make sure `/mnt/NAS/torrent` exists or update the path in the config.

### 9. SSH Keys
Make sure to set up SSH keys properly:
```bash
chmod 600 /home/romain/.ssh/config
chmod 600 /home/romain/.ssh/id_*  # if you have keys
```

### 10. Zsh Setup
Install Oh My Zsh and plugins:
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# Install zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# Install zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

## Notes

- The configuration assumes username "romain" - adjust paths if using a different username
- Some paths like `/mnt/NAS` may need to be created or adjusted
- The SSH config includes references to other machines that may not exist in your network
- Some aliases and functions in `.zshrc` are Nix-specific and may need adjustment for non-NixOS systems
