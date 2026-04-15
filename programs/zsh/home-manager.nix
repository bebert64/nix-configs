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
  inherit (homeManagerBydbConfig) paths;
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
      wke1 = "swaymsg workspace 11:󰸉";
      wke2 = "swaymsg workspace 12:󰸉";
      ssh = "kitten ssh";
      cargo2nix = "cdr && cargo2nix -ol && cd -";
      dc = "db-cli";

      # Nix
      update = "run-in-nix-repo nix-switch";
      update-dirty = "run-in-nix-repo-dirty nix-switch";
      update-clean = "run-in-nix-repo 'sudo nix-collect-garbage -d && nix-switch'";
      update-raspi4 =
        "run-in-nix-repo '"
        + "b=$(git branch --show-current); "
        + "GIT_BRANCH=$b inhibit-and-sleep nixos-rebuild build --flake .#raspi4 --impure"
        + " && GIT_BRANCH=$b nixos-rebuild switch --target-host raspi4 --sudo --ask-sudo-password --flake .#raspi4 --impure"
        + "'";

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
          local idle_since_us=$(loginctl show-session "$XDG_SESSION_ID" -p IdleSinceHint --value 2>/dev/null)
          local sleep_threshold_ms=${
            toString (
              (homeManagerBydbConfig.minutesBeforeLock + homeManagerBydbConfig.minutesFromLockToSleep) * 60 * 1000
            )
          }
          if [[ -n "$idle_since_us" && "$idle_since_us" != "0" ]]; then
            local now_us=$(( $(date +%s) * 1000000 ))
            local idle_ms=$(( (now_us - idle_since_us) / 1000 ))
            if (( idle_ms >= sleep_threshold_ms )); then
              systemctl suspend
            fi
          fi
        ''}
        return $exit_code
      }

      nix-switch() {
        local git_branch
        git_branch=$(git branch --show-current)
        inhibit-and-sleep "GIT_BRANCH=$git_branch env -u LD_LIBRARY_PATH nixos-rebuild build --flake .# --impure" || return 1
        ${pkgs.libnotify}/bin/notify-send -u critical 'nix-switch' 'Build done — sudo password needed to switch'
        inhibit-and-sleep "sudo GIT_BRANCH=$git_branch env -u LD_LIBRARY_PATH nixos-rebuild switch --flake .# --impure"
      }

      _nix-repo-dir() {
        local cwd="$PWD"
        local base="${paths.nixConfigs}"
        local parent="$(dirname "$base")"
        local name="$(basename "$base")"
        # If we're inside a nix-configs worktree, use it
        if [[ "$cwd" == "$parent/$name" || "$cwd" == "$parent/$name/"* || \
              "$cwd" == "$parent/''${name}_"* ]]; then
          # Extract the worktree root (parent/name or parent/name_suffix)
          local rel="''${cwd#$parent/}"
          echo "$parent/''${rel%%/*}"
        else
          echo "$base"
        fi
      }
      run-in-nix-repo() {
        local dir=$(_nix-repo-dir)
        cd "$dir"
        [[ "$dir" == "${paths.nixConfigs}" ]] && { git pull || return 1; }
        (eval "$*")
        cd -
      }
      run-in-nix-repo-dirty() {
        local dir=$(_nix-repo-dir)
        cd "$dir"
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

        # Create worktree and branch via db-cli
        wk_output=$(db-cli wk "Update flake inputs" 2>&1) || { echo "$wk_output"; cd "$orig_dir"; return 1; }
        wk_path=$(echo "$wk_output" | grep -oP '(?<=cd )\S+')
        cd "$wk_path" || { echo "Failed to cd to worktree: $wk_path"; cd "$orig_dir"; return 1; }
        direnv allow

        # Update nixpkgs to latest stable branch
        latest=$(gh api repos/NixOS/nixpkgs/branches --paginate -q '.[].name' \
          | grep -E '^nixos-[0-9]{2}\.[0-9]{2}$' | sort -V | tail -1)
        sed -i "s|nixpkgs/nixos-[0-9]*\.[0-9]*|nixpkgs/$latest|" flake.nix

        cd nix/dev
        nix flake update
        cdr
        nix flake update

        git add .
        git commit -m "Update flake inputs"
        git push

        if cargo check && cargo clippy; then
          gh pr merge --squash
          local branch=$(git branch --show-current)
          cd "$orig_dir"
          git -C "${paths.mainWorktree}" worktree remove "$wk_path"
          git -C "${paths.mainWorktree}" branch -D "$branch"
          git -C "${paths.mainWorktree}" pull
          return
        else
          echo "Checks failed. Fix issues in: $wk_path"
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

      _cdm_complete() {
        local base git_root
        git_root=$(git rev-parse --show-toplevel 2>/dev/null)
        if [[ "$git_root" == *"/nix-configs"* ]] || [[ "$git_root" == *"/nix-configs_"* ]]; then
          base="${paths.nixConfigs}"
        else
          base="${paths.mainWorktree}"
        fi
        _files -W "$base" -/
      }
      compdef _cdm_complete cdm
      cdm() {
        local base git_root
        git_root=$(git rev-parse --show-toplevel 2>/dev/null)
        if [[ "$git_root" == *"/nix-configs"* ]] || [[ "$git_root" == *"/nix-configs_"* ]]; then
          base="${paths.nixConfigs}"
        else
          base="${paths.mainWorktree}"
        fi
        cd "$base/$@"
      }

      _cdn_complete() {
        local base git_root
        git_root=$(git rev-parse --show-toplevel 2>/dev/null)
        if [[ "$git_root" == *"/nix-configs"* ]] || [[ "$git_root" == *"/nix-configs_"* ]]; then
          base="$git_root"
        else
          base="${paths.nixConfigs}"
        fi
        _files -W "$base" -/
      }
      compdef _cdn_complete cdn
      cdn() {
        local base git_root
        git_root=$(git rev-parse --show-toplevel 2>/dev/null)
        if [[ "$git_root" == *"/nix-configs"* ]] || [[ "$git_root" == *"/nix-configs_"* ]]; then
          base="$git_root"
        else
          base="${paths.nixConfigs}"
        fi
        cd "$base/$@"
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
