# Nix Crate Packaging — Personal Monorepo (Main)

Every installable crate in the personal monorepo has a `.nix` file that provides a home-manager module for installing the binary and optionally generating its `.toml` config.

## File layout

```
CrateName/
  Cargo.toml
  src/
  crate-name.nix          # kebab-case, matches Cargo package name
```

The file is then registered in `nix/default.nix`:

```nix
crates = {
  crate-name = ../CrateName/crate-name.nix;
};
```

`flake.nix` imports `nix/default.nix`, collects all `package` and `module` exports, and exposes them as flake outputs.

## Skeleton — minimal (no config)

Use when the crate reads no config file at all.

```nix
{
  rustPkgs,
  ...
}:
rec {
  package = (rustPkgs.workspace.crate-name { });

  module =
    { lib, config, ... }:
    let
      inherit (lib)
        mkIf
        mkEnableOption
        ;
    in
    {
      options.byDbPkgs.crate-name = {
        enable = mkEnableOption "crate-name";
      };

      config =
        let
          cfg = config.byDbPkgs.crate-name;
        in
        {
          home = mkIf cfg.enable {
            packages = [
              package
            ];
          };
        };
    };
}
```

## Skeleton — with TOML config

Use when the crate uses `config_helpers::config!("crate-name")` and reads a `.toml`.

```nix
{
  rustPkgs,
  ...
}:
rec {
  package = (rustPkgs.workspace.crate-name { });

  module =
    { lib, config, ... }:
    let
      inherit (lib)
        mkIf
        mkEnableOption
        mkOption
        types
        ;
      inherit (types) str;
    in
    {
      options.byDbPkgs.crate-name = {
        enable = mkEnableOption "crate-name";
        someOption = mkOption { type = str; };
        nested = {
          field = mkOption { type = str; };
        };
      };

      config =
        let
          cfg = config.byDbPkgs.crate-name;
        in
        {
          home = mkIf cfg.enable {
            file.".config/by_db/crate-name.toml".text = ''
              some_option = "${cfg.someOption}"

              [nested]
                field = "${cfg.nested.field}"
            '';

            packages = [
              package
            ];
          };
        };
    };
}
```

## TOML generation rules

- Config is written to `~/.config/by_db/{crate-name}.toml` via `home.file`
- Nix option names use camelCase; TOML keys use snake_case
- TOML structure must match the Rust `Config` struct from `src/config.rs`
- For secrets, use a `*File` option (path to a file containing the secret) rather than inlining the secret value

## Optional additions

These are **only added when the crate needs them** — most crates don't.

### Extra build inputs

When the crate needs runtime binaries (e.g. `ffmpeg`, `yt-dlp`):

```nix
{ pkgs, rustPkgs, ... }:
rec {
  package = (rustPkgs.workspace.crate-name { });
  # ...
  packages = [ package pkgs.ffmpeg ];
}
```

Also declare them in the `makeCrateOverrides` section of `flake.nix` if they're needed at build time.

### Shell aliases

```nix
programs.zsh.shellAliases = mkIf cfg.enable {
  alias-name = "${package}/bin/crate-name subcommand";
};
```

### Systemd user service + timer

```nix
systemd.user = mkIf cfg.service.enable {
  enable = true;
  services.crate-name = {
    Unit.Description = "Description";
    Service = {
      Type = "oneshot";
      ExecStart = "${package}/bin/crate-name";
    };
  };
  timers.crate-name = {
    Unit.Description = "Timer for crate-name";
    Timer = {
      Unit = "crate-name.service";
      OnCalendar = "${cfg.service.runAt}";
    };
    Install.WantedBy = [ "timers.target" ];
  };
};
```

## Checklist — adding a new crate

1. Create `CrateName/crate-name.nix` using the appropriate skeleton above
2. Register it in `nix/default.nix`
3. Run `nix flake check` or `nix build .#crate-name` to verify
4. If the crate has a `Config` struct, ensure the generated TOML matches its shape exactly (field names, nesting)
