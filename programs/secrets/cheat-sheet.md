# Stockly database URI (for agents / investigations)

To add the main Stockly DB URI so the agent can use it via `sops-read stockly/main-db-uri`:

1. Run `sops-edit` (or `sops secrets.yaml` from this directory).
2. Add under the root YAML:
   ```yaml
   stockly:
     main-db-uri: "postgresql://..."
   ```
3. Replace with the real URI, save and exit. SOPS will encrypt the value.

The agent is instructed (see Stockly `.cursor/rules/database-access.mdc`) to run `sops-read stockly/main-db-uri` when it needs the URI and never to store it in clear.

---

# Generate private key

```
mkdir -p $HOME/.config/sops/age
nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i $HOME/.ssh/id_ed25519"
```

# Generate associated public key

```
nix-shell -p ssh-to-age --run "ssh-to-age < ~/.ssh/id_ed25519.pub"
```
