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

# Make scripts executable
chmod +x /home/romain/.local/bin/*
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

#### NAS Mount Configuration

The NAS mount scripts and systemd services are provided. Set them up as follows:

1. **Make scripts executable:**

```bash
chmod +x /home/romain/.local/bin/mount-nas
chmod +x /home/romain/.local/bin/unmount-nas
```

2. **Install NFS client (if not already installed):**

```bash
sudo apt-get install nfs-common
```

3. **Add fstab entry (optional, for manual mounting):**
   Add this line to `/etc/fstab`:

```
192.168.1.3:/volume1/NAS /mnt/NAS nfs noexec,noauto 0 0
```

4. **Copy systemd service and timer:**

```bash
sudo cp etc/systemd/system/mount-nas.service /etc/systemd/system/
sudo cp etc/systemd/system/mount-nas.timer /etc/systemd/system/
```

5. **Enable and start the timer:**

```bash
sudo systemctl daemon-reload
sudo systemctl enable mount-nas.timer
sudo systemctl start mount-nas.timer
```

6. **Create mount point and symlink:**

```bash
sudo mkdir -p /mnt/NAS
mkdir -p ~/mnt
ln -sf /mnt/NAS ~/mnt/
```

**Note:** The NAS mount scripts will automatically:

- Check if NAS is already mounted
- Ping the NAS to verify it's reachable
- Verify the NAS identity by checking port 5000
- Mount the NFS share at `/mnt/NAS`
- The timer will attempt to mount every 5 minutes and on boot (after 20 seconds)

You can also manually mount/unmount using:

- `mnas` or `mount-nas` to mount
- `umnas` or `unmount-nas` to unmount

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

### 11. Set Default Editor

Set neovim as the default editor for all text files (including JSON, TOML, etc.):

1. **Set system-wide default editor:**

```bash
sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 1
sudo update-alternatives --set editor /usr/bin/nvim
```

2. **Set environment variables in `.profile` (so they're available to all processes, including ranger):**

```bash
echo 'export EDITOR="nvim"' >> ~/.profile
echo 'export VISUAL="nvim"' >> ~/.profile
```

**Note:** These are also set in `.zshrc`, but `.profile` ensures they're available even when ranger is launched from a GUI or without a login shell.

After setting these, neovim will be used as the default editor for:

- Text files opened in ranger (via `EDITOR`/`VISUAL` variables)
- Git commits and other git operations
- System tools that use the `editor` command
- Any application that respects the `EDITOR` or `VISUAL` environment variables

3. **Install neovim plugin manager and plugins:**
   The neovim config uses vim-plug to manage plugins. Install it manually:

```bash
# Install vim-plug
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install plugins (catppuccin theme)
nvim +PlugInstall +qall
```

The catppuccin theme will be automatically applied on the next neovim launch.

## Notes

- The configuration assumes username "romain" - adjust paths if using a different username
- Some paths like `/mnt/NAS` may need to be created or adjusted
- The SSH config includes references to other machines that may not exist in your network
- Some aliases and functions in `.zshrc` are Nix-specific and may need adjustment for non-NixOS systems
