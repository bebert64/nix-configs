{
  config,
  lib,
  ...
}:
{
  options.by-db = with lib; {
    nixConfigsRepo = mkOption {
      type = types.str;
      default = "nix-configs";
    };
    mainCodingRepo = mkOption {
      type = types.str;
      default = "code";
    };

  };

  config.programs.zsh =
    let
      cfg = config.by-db;
      formatOptions = "comment_width=120,condense_wildcard_suffixes=false,format_code_in_doc_comments=true,format_macro_bodies=true,hex_literal_case=Upper,imports_granularity=One,normalize_doc_attributes=true,wrap_comments=true";
    in
    {
      enable = true;
      shellAliases = {
        wke1 = "i3-msg workspace 11:󰸉";
        wke2 = "i3-msg workspace 12:󰸉";
        cargo2nix = "cdr && cargo2nix -ol && cd -";

        # Nix aliases
        nix-shell = "nix-shell --run zsh";
        update = "run-in-nix-repo nix-switch";
        update-dirty = "run-in-nix-repo-dirty nix-switch";
        update-clean = "run-in-nix-repo 'sudo nix-collect-garbage -d && nix-switch'";
        update-raspi = "run-in-nix-repo systemd-inhibit 'nixos-rebuild build --flake .#raspi && nixos-rebuild switch --target-host raspi --use-remote-sudo --flake .#raspi'";

        # Cargo aliases
        tfw = "run-in-code-repo 'cargo fmt -- --config \"${formatOptions}\" && cargo test'";
        ccw = "run-in-code-repo 'cargo check'";
        cccw = "run-in-code-repo 'cargo clean && cargo check'";
        cctfw = "run-in-code-repo 'cargo fmt -- --config \"${formatOptions}\" && cargo clean && cargo test'";
      };
      history = {
        size = 200000;
        save = 200000;
        extended = true; # save timestamps
      };
      oh-my-zsh = {
        enable = true;
      };
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      initContent = ''
        # Helpers
        run-in-nix-repo() {
          cd ~/${cfg.nixConfigsRepo}
          git pull || return 1
          (eval "$*")
          cd -
        }
        run-in-nix-repo-dirty() {
          cd ~/${cfg.nixConfigsRepo}
          (eval "$*")
          cd -
        }
        run-in-code-repo() {
          cd ~/${cfg.mainCodingRepo}
          (eval "$*")
          cd -
        }

        # Upgrades
        nix-switch() {
          # Defined as a function rather than an alias to allow being called from other functions
          sudo systemd-inhibit nixos-rebuild switch --flake .#
        };
        upgrade-code() {
          orig_dir="$(pwd)"
          cdr
          git pull || return 1
          cdr nix/dev
          nix flake update
          cdr
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
          # Defined as a function rather than an alias to allow being called from other functions
          run-in-nix-repo 'nix flake update --commit-lock-file && nix-switch'
          git push
        }
        upgrade-full() {
          setopt aliases
          upgrade-code || return 1
          upgrade-nix
        }

        # Cdr and completion
        compdef '_files -W "$HOME/${cfg.mainCodingRepo}" -/' cdr
        cdr() {
          cd "$HOME/${cfg.mainCodingRepo}/$@"
        }

        # Other
        psg() {
          ps aux | grep $1 | grep -v psg | grep -v grep
        }
        run() {
          nix run "nixpkgs#$1" -- "''${@:2}"
        }
        sync-wallpapers() {
          rsync -avh --exclude "Fond pour téléphone" $HOME/mnt/NAS/Wallpapers/ ~/wallpapers
          rsync -avh ~/wallpapers/ $HOME/mnt/NAS/Wallpapers
        }
        wsshfb() {
          ssh raspi "wol D4:3D:7E:D8:C3:95"
          while ssh raspi "! ping -c1 192.168.1.4 &> /dev/null"; do
            echo "fixe-bureau is not responding"
            sleep 1
          done
          ssh fixe-bureau -t "xset -display :0.0 dpms force off; DISPLAY=:0.0 nohup alock -cursor blank &; zsh -i"
        }

        path+="$HOME/.cargo/bin"
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
