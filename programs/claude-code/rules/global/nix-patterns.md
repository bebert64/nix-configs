---
applies_to: "*.nix"
---

## Merging static JSON config with dynamic Nix values

When a config file is mostly static but needs a few runtime-computed values injected (paths, secrets, machine-specific data), keep the static parts in a checked-in JSON file and merge at build time:

```nix
let
  mergedConfig = pkgs.writeText "config.json" (builtins.toJSON (
    (builtins.fromJSON (builtins.readFile ./config.json)) // {
      someKey = "dynamically computed value";
    }
  ));
```

This keeps the bulk of the config readable and diff-able in the repo while letting Nix inject computed values. Prefer this over duplicating the static content inline in Nix or over generating the entire file from Nix.
