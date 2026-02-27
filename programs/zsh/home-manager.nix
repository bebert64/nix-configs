{
  config,
  options,
  pkgs,
  lib,
  ...
}:
let
  common = import ./common.nix;
  homeManagerBydbConfig = config.byDb;
  paths = homeManagerBydbConfig.paths;
  homeDir = config.home.homeDirectory;
  formatOptions = "comment_width=120,condense_wildcard_suffixes=false,format_code_in_doc_comments=true,format_macro_bodies=true,hex_literal_case=Upper,imports_granularity=One,normalize_doc_attributes=true,wrap_comments=true";
  hasLock = options.byDb ? minutesBeforeLock;
in
{
  config.programs.zsh = {
    enable = true;
    history = {
      size = common.historySize;
      save = common.historySize;
      extended = common.extendedHistory;
    };
    shellAliases = {
      wke1 = "i3-msg workspace 11:󰸉";
      wke2 = "i3-msg workspace 12:󰸉";
      cargo2nix = "cdr && cargo2nix -ol && cd -";

      # Nix
      update = "run-in-nix-repo nix-switch";
      update-dirty = "run-in-nix-repo-dirty nix-switch";
      update-clean = "run-in-nix-repo 'sudo nix-collect-garbage -d && nix-switch'";
      update-raspi4 = "run-in-nix-repo 'inhibit-and-sleep nixos-rebuild build --flake .#raspi4 && nixos-rebuild switch --target-host raspi4 --sudo --ask-sudo-password --flake .#raspi4'";

      # Cargo
      tfw = "run-in-code-repo 'cargo fmt -- --config \"${formatOptions}\" && cargo test'";
      ccw = "run-in-code-repo 'cargo check'";
      cccw = "run-in-code-repo 'cargo clean && cargo check'";
      cctfw = "run-in-code-repo 'cargo fmt -- --config \"${formatOptions}\" && cargo clean && cargo test'";
    };
    initContent = ''
      inhibit-and-sleep() {
        systemd-inhibit bash -c "$*"
        local exit_code=$?
        ${lib.optionalString hasLock ''
          local idle_ms=$(${pkgs.xprintidle}/bin/xprintidle)
          local sleep_threshold_ms=${
            toString (
              (homeManagerBydbConfig.minutesBeforeLock + homeManagerBydbConfig.minutesFromLockToSleep) * 60 * 1000
            )
          }
          if (( idle_ms >= sleep_threshold_ms )); then
            systemctl suspend
          fi
        ''}
        return $exit_code
      }

      nix-switch() {
        inhibit-and-sleep 'env -u LD_LIBRARY_PATH nixos-rebuild build --flake .# && sudo env -u LD_LIBRARY_PATH nixos-rebuild switch --flake .#'
      }

      run-in-nix-repo() {
        cd ${paths.nixConfigs}
        git pull || return 1
        (eval "$*")
        cd -
      }
      run-in-nix-repo-dirty() {
        cd ${paths.nixConfigs}
        (eval "$*")
        cd -
      }
      run-in-code-repo() {
        cd ${paths.mainWorktree}
        (eval "$*")
        cd -
      }

      upgrade-code() {
        orig_dir="$(pwd)"
        cdm
        git pull || return 1
        cdm nix/dev
        nix flake update
        cdm
        nix flake update
        if cargo check; then
          git add .
          git commit -m "Update flake inputs"
          git push
        else
          git reset --hard
          cd "$orig_dir"
          return 1
        fi
        cd "$orig_dir"
      }
      upgrade-nix() {
        run-in-nix-repo 'nix flake update --commit-lock-file && git push && nix-switch'
      }
      upgrade-full() {
        setopt aliases
        upgrade-code || return 1
        upgrade-nix
      }

      _cdr_complete() {
        local base git_root
        git_root=$(git rev-parse --show-toplevel 2>/dev/null)
        if [[ "$git_root" == ${paths.codeRoot}/Main* ]]; then
          base="$git_root"
        else
          base="${paths.mainWorktree}"
        fi
        _files -W "$base" -/
      }
      compdef _cdr_complete cdr
      cdr() {
        local base git_root
        git_root=$(git rev-parse --show-toplevel 2>/dev/null)
        if [[ "$git_root" == ${paths.codeRoot}/Main* ]]; then
          base="$git_root"
        else
          base="${paths.mainWorktree}"
        fi
        cd "$base/$@"
      }

      unalias dc 2>/dev/null
      dc() {
        cd ${paths.mainWorktree}
        cargo run -p db_cli -- "$@"
        cd -
      }

      compdef '_files -W "${paths.mainWorktree}" -/' cdm
      cdm() {
        cd "${paths.mainWorktree}/$@"
      }

      compdef '_files -W "${paths.nixConfigs}" -/' cdn
      cdn() {
        cd "${paths.nixConfigs}/$@"
      }

      s() {
        if [[ "$1" == "wk" ]]; then
          command s wk "''${@:2}" -w=b
        elif [[ "$1" == "tk" ]] && [[ " $* " == *" wk "* ]]; then
          command s "$@" -w=b
        else
          command s "$@"
        fi
      }

      sync-wallpapers() {
        rsync -avh --exclude "Fond pour téléphone" ${paths.nasBase}/Wallpapers/ ${homeDir}/wallpapers
        rsync -avh ${homeDir}/wallpapers/ ${paths.nasBase}/Wallpapers
      }

      path+="${homeDir}/.cargo/bin"
      eval "$(direnv hook zsh)"
    '';
    plugins = [
      {
        name = "stockly";
        src = ./OhMyZsh;
        file = "stockly.zsh-theme";
      }
      {
        name = "git";
        src = ./OhMyZsh;
        file = "git.zsh";
      }
    ];
  };
}
