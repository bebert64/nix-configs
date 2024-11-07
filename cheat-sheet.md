# Manual operations still needed

## Accounts syncing

- Setup 1password accounts (info for both accounts are on NAS)
- Sync firefox profiles
- Login / sync setting for VsCode / DataGrip / Slack
- Import database sources for DataGrip

```
cd ... && cp ...
```

<br />

## SSH

- Generate key with

```
ssh-keygen -t ed25519
```

- Copy on github account / charybdis
- Might need to add this computer to general ssh config and add other keys
  <br />

# Pacman / Yay

## List all packages installed by user

pacman/yay -Qqe

## Remove a package and all its unused dependencies

pacman/yay -Rns

# Various

## Screen

type `screen` before starting long task
start long task
if disconnected, reconnect and type `screen -r` to reconnect

## Reinstall nixos boot

sudo nix-collect-garbage -d
sudo nixos-rebuild switch --flake .#

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

- copy them in fonts folder inside configs
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
