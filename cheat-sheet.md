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

After that, copy the fingerprint from setup and the config inside host-specifics + update the launch script
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

## Add fonts

- copy them in fonts folder inside configs
- rebuild
- reset font cache

```
fc-cache -f -v
```

reinstall nixos boot
sudo nix-collect-garbage -d
sudo nixos-rebuild switch --flake .#
