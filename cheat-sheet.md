# Manual operations still needed
- Setup 1password accounts (info for both accounts are on NAS)
- Login / sync setting for VsCode / DataGrip / Slack
- Import database sources for DataGrip
- Create and sync firefox profiles
- Copy profile from existing Thunderbird  
  <br />
  <br />

# SSH Key
- Generate with 
```
ssh-keygen -t ed25519
```
- Copy on github account / charybdis
- Might need to add this computer to general ssh config and add other keys

# To sync Tilix settings

- dump somewhere  
```
dconf dump /com/gexperts/Tilix/ > tilix.dconf
```  
- load  
```
dconf load /com/gexperts/Tilix/ < tilix.dconf
```
