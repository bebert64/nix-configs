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
        nix-shell = "nix-shell --run zsh";
        cargo2nix = "cdr && cargo2nix -ol && cd -";
        wol-fixe-bureau = "ssh raspi \"wol D4:3D:7E:D8:C3:95\"";
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
        # Nix updates
        update-dirty() {
          cd ~/${cfg.nixConfigsRepo}
          systemd-inhibit sudo nixos-rebuild switch --flake .#
          cd -
        }
        update() {
          cd ~/${cfg.nixConfigsRepo}
          git pull || return 1
          systemd-inhibit sudo nixos-rebuild switch --flake .#
          cd -
        }
        update-clean() {
          cd ~/${cfg.nixConfigsRepo}
          git pull || return 1
          systemd-inhibit sudo bash -c 'nix-collect-garbage -d && nixos-rebuild switch --flake .#'
          cd -
        }
        update-raspi() {
          cd ~/${cfg.nixConfigsRepo}
          git pull || return 1
          systemd-inhibit 'nixos-rebuild build --flake .#raspi && nixos-rebuild switch --target-host raspi --use-remote-sudo --flake .#raspi'
          cd -
        }
        upgrade-nix() {
          cd ~/${cfg.nixConfigsRepo}
          git pull || return 1
          systemd-inhibit 'nix flake update --commit-lock-file && sudo nixos-rebuild switch --flake .#'
          git push
          cd -
        }
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
        upgrade-full() {
          upgrade-code || return 1
          upgrade-nix
        }

        # Code/cargo commands
        compdef '_files -W "$HOME/${cfg.mainCodingRepo}" -/' cdr
        cdr() {
          cd "$HOME/${cfg.mainCodingRepo}/$@"
        }
        tfw() {
          cdr
          cargo fmt -- --config "${formatOptions}"
          cargo test
          cd -
        }
        ccw() {
          cdr
          cargo check 
          cd -
        }
        cccw() {
          cdr
          cargo clean
          cargo check
          cd -
        }
        cctfw() {
          cdr
          cargo fmt -- --config "${formatOptions}"
          cargo clean
          cargo test
          cd -
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
