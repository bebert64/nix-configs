{
  config,
  lib,
  ...
}:
let
  byDbHomeManager = config.by-db;
in
{
  options.by-db = {
    mainCodingRepo = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/code";
      description = "Name of the main coding repo directory — used for cdr and related zsh helpers";
    };

    mainCodingPath = lib.mkOption {
      type = lib.types.str;
      internal = true;
      readOnly = true;
      default = "${config.home.homeDirectory}/${config.by-db.mainCodingRepo}";
      description = "Full path to the main coding repo";
    };
  };

  config.programs.zsh =
    let
      formatOptions = "comment_width=120,condense_wildcard_suffixes=false,format_code_in_doc_comments=true,format_macro_bodies=true,hex_literal_case=Upper,imports_granularity=One,normalize_doc_attributes=true,wrap_comments=true";
    in
    {
      enable = true;
      shellAliases = {
        wke1 = "i3-msg workspace 11:󰸉";
        wke2 = "i3-msg workspace 12:󰸉";
        cargo2nix = "cdr && cargo2nix -ol && cd -";

        # Systemd
        jc = "journalctl -xefu";
        jcb = "jc backup --user";
        jcc = "jc comfyui";
        jcgt = "jc guitar-tutorials --user";
        jcg = "jc guitar --user";
        jcm = "jc media --user";
        jcs = "jc shortcuts --user";
        jcwd = "jc wallpapers-download --user";
        ss = "systemctl status";
        ssc = "ss comfyui";
        ssg = "ss guitar --user";
        ssm = "ss media --user";
        ssq = "ss qbittorrent --user";
        sss = "ss stash --user";

        # Nix
        nix-shell = "nix-shell --run zsh";
        update = "run-in-nix-repo nix-switch";
        update-dirty = "run-in-nix-repo-dirty nix-switch";
        update-clean = "run-in-nix-repo 'sudo nix-collect-garbage -d && nix-switch'";
        update-raspi4 = "run-in-nix-repo systemd-inhibit 'nixos-rebuild build --flake .#raspi4 && nixos-rebuild switch --target-host raspi4 --sudo --ask-sudo-password --flake .#raspi4'";

        # Cargo
        tfw = "run-in-code-repo 'cargo fmt -- --config \"${formatOptions}\" && cargo test'";
        ccw = "run-in-code-repo 'cargo check'";
        cccw = "run-in-code-repo 'cargo clean && cargo check'";
        cctfw = "run-in-code-repo 'cargo fmt -- --config \"${formatOptions}\" && cargo clean && cargo test'";
      };
      initContent = ''
        # Helpers
        run-in-nix-repo() {
          cd ${byDbHomeManager.paths.nixConfigs}
          git pull || return 1
          (eval "$*")
          cd -
        }
        run-in-nix-repo-dirty() {
          cd ${byDbHomeManager.paths.nixConfigs}
          (eval "$*")
          cd -
        }
        run-in-code-repo() {
          cd ${byDbHomeManager.mainCodingPath}
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
          run-in-nix-repo 'nix flake update --commit-lock-file && git push && nix-switch'
        }
        upgrade-full() {
          setopt aliases
          upgrade-code || return 1
          upgrade-nix
        }

        # Cdr and completion
        compdef '_files -W "${byDbHomeManager.mainCodingPath}" -/' cdr
        cdr() {
          cd "${byDbHomeManager.mainCodingPath}/$@"
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
        wol-ssh() {
          ssh raspi5 "/home/romain/.local/bin/wol-by-db $2"
          while ssh raspi5 "! ping -c1 $3 &> /dev/null"; do
            echo "$1 is not responding"
            sleep 1
          done
          ssh $1 -t "zsh -i"
        }
        wb() {
          wol-ssh bureau D4:3D:7E:D8:C3:95 192.168.1.4
        }
        ws() {
          wol-ssh salon 74:56:3c:36:71:db 192.168.1.6
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
