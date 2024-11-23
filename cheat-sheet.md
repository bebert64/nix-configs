## SSH

- Generate key with

```
ssh-keygen -t ed25519
```

- Copy on github account / charybdis
- Might need to add this computer to general ssh config and add other keys
  <br />

# Various

## Screen

type `screen` before starting long task
start long task
if disconnected, reconnect and type `screen -r` to reconnect

## To sync Tilix settings

- dump somewhere

```
dconf dump /com/gexperts/Tilix/ > tilix.dconf
```

- load

```
dconf load /com/gexperts/Tilix/ < tilix.dconf
```

<br />
<br />

## Fonts

### Add new fonts

- check if available as a nix package (prefered option)
- if not
  - copy them in fonts folder inside configs
  - symlink files to appropriate folder (if not already in setup)
  - rebuild
  - reset font cache

```
fc-cache -f -v
```

### Use special characters

The font used in this setup is "Iosevka Nerd Font". To make VsCode display those characters correctly, add the font's
name to settings `Editor: Font Family`
To insert a new character, search for it on https://www.nerdfonts.com/cheat-sheet and copy/paste it as Icon

# Comics

## Script for reference

```bash
#!/usr/bin/env bash
set -euxo pipefail

for n in $(seq 1 $#); do
    echo $1
    mkdir zip
    zip "zip/$1.zip" "$1"/*
    rsync --progress "zip/$1.zip" /home/romain/mnt/Ipad/Chunky
    rsync --progress "$1" /home/romain/mnt/Ipad/Chunky
    shift
done
```

Raspi

Build image
nix build .#nixosConfigurations.raspi.config.system.build.sdImage

copy img to SD card (can also use rpi-imager)
sudo dd if=nixos-sd-image-23.05pre482417.9c7cc804254-aarch64-linux.img of=/dev/sdX r

backup sd card
sudo dd if=/dev/sdX of=raspi.img bs=4096 conv=fsync status=progress

deploy remotely (might need to also git pull from nix-configs to update symlinks)
nix-rebuild switch --target-host raspi --build-host localhost --use-remote-sudo --flake .#raspi
