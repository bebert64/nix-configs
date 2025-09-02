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
    mainCodingRepo = {
      path = mkOption {
        type = types.str;
        default = "code";
      };
      workspaceDir = mkOption {
        type = types.str;
        default = ".";
      };
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
        c = "code .";
        cc = "code $HOME/${cfg.mainCodingRepo.path}";
        cn = "code $HOME/${cfg.nixConfigsRepo}";
        cs = "code --folder-uri=vscode-remote://ssh-remote+cerberus/home/romain/Stockly/Main";
        cso = "code --folder-uri=vscode-remote://ssh-remote+cerberus/home/romain/Stockly/Main/operations/Service";
        wke1 = "i3-msg workspace 11:󰸉";
        wke2 = "i3-msg workspace 12:󰸉";
        de = "yt-dlp -f 720p_HD";
        nix-shell = "nix-shell --run zsh";
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
        }
        update() {
          cd ~/${cfg.nixConfigsRepo}
          git pull
          systemd-inhibit sudo nixos-rebuild switch --flake .#
        }
        update-clean() {
          cd ~/${cfg.nixConfigsRepo}
          git pull
          systemd-inhibit sudo nix-collect-garbage -d
          systemd-inhibit sudo nixos-rebuild switch --flake .#
        }
        update-raspi() {
          cd ~/${cfg.nixConfigsRepo}
          git pull
          systemd-inhibit nixos-rebuild switch --target-host raspi --build-host localhost --use-remote-sudo --flake .#raspi
        }
        upgrade() {
          cd ~/${cfg.nixConfigsRepo}
          git pull
          systemd-inhibit nix flake update --commit-lock-file
          systemd-inhibit sudo nixos-rebuild switch --flake .#
          git push
        }
        upgrade-full() {
          cdr && nix flake update
          cdr nix/dev && nix flake update
          cargo check && cdr && git add . && git commit -m "Update flake inputs" && git push
          cd ~/${cfg.nixConfigsRepo}
          git pull
          systemd-inhibit nix flake update --commit-lock-file
          systemd-inhibit sudo nixos-rebuild switch --flake .#
          git push
        }

        # Code/cargo commands
        compdef '_files -W "$HOME/${cfg.mainCodingRepo.path}" -/' cdr
        cdr() {
          cd "$HOME/${cfg.mainCodingRepo.path}/$@"
        }
        tfw() {
          cdr ${cfg.mainCodingRepo.workspaceDir}
          cargo test
          cargo fmt -- --config "${formatOptions}"
          cd -
        }
        ccw() {
          cdr ${cfg.mainCodingRepo.workspaceDir}
          cargo check 
          cd -
        }
        cccw() {
          cdr ${cfg.mainCodingRepo.workspaceDir}
          cargo clean
          cargo check
          cd -
        }
        cctfw() {
          cdr ${cfg.mainCodingRepo.workspaceDir}
          cargo clean
          cargo test
          cargo fmt -- --config "${formatOptions}"
          cd -
        }

        # Wake on LAN fixe-bureau
        wol-fixe-bureau() {
          ssh raspi "wol D4:3D:7E:D8:C3:95"
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
