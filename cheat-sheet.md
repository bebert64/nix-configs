# To sync Tilix settings

dump somewhere  
```
dconf dump /com/gexperts/Tilix/ > tilix.dconf
```  
load  
```
dconf load /com/gexperts/Tilix/ < tilix.dconf
```
