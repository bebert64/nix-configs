# Manual operations still needed
- Setup 1password accounts (info for both accounts are on NAS)
- Login / sync setting for VsCode / DataGrip / Slack
- Import database sources for DataGrip
- Create and sync firefox profiles
- Copy profile from existing Thunderbird  
  <br />
  <br />
# To sync Tilix settings

dump somewhere  
```
dconf dump /com/gexperts/Tilix/ > tilix.dconf
```  
load  
```
dconf load /com/gexperts/Tilix/ < tilix.dconf
```
