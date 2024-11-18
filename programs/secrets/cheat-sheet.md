# Generate private key

```
mkdir -p $HOME/.config/sops/age
nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i $HOME/.ssh/id_ed25519"
```

# Generate associated public key

```
nix-shell -p ssh-to-age --run "ssh-to-age < ~/.ssh/id_ed25519.pub"
```
