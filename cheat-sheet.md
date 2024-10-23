# Manual operations still needed

## Accounts syncing

- Setup 1password accounts (info for both accounts are on NAS)
- Create and sync firefox profiles
- Login / sync setting for VsCode / DataGrip / Slack
- Import database sources for DataGrip

```
cd ... && cp ...
```

- Copy profile from existing Thunderbird (into correct account a.k.a. Regular)

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

## Autorandr

- save a profile

```
autorandr --save profile-name
```

After that, copy the fingerprint from setup and the config inside host-specific + update the launch script
<br />

# Annexes

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

# Add new fonts

- copy them in fonts folder inside configs
- rebuild
- reset font cache

```
fc-cache -f -v
```

# Use special characters

The font used in this setup is "Iosevka Nerd Font". To make VsCode display those characters correctly, add the font's
name to settings `Editor: Font Family`
To insert a new character, search for it on https://www.nerdfonts.com/cheat-sheet and copy/paste it as Icon

## Reinstall nixos boot

sudo nix-collect-garbage -d
sudo nixos-rebuild switch --flake .#
