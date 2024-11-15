{ config, lib, ... }:
{
  options.by-db = with lib; {
    nixConfigsRepo = mkOption {
      type = types.str;
      default = "nix-configs";
    };
    mainCodingRepo = {
      path = mkOption {
        type = types.str;
        default = "$HOME/code";
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
    in
    {
      enable = true;
      shellAliases = {
        "c" = "code .";
        "wke1" = "i3-msg workspace \"\\\" \\\"\"";
        "de" = "yt-dlp -f 720p_HD";
        "update" = "cd ~/${cfg.nixConfigsRepo} && git pull && sudo nixos-rebuild switch --flake .#";
        "update-clean" = "cd ~/${cfg.nixConfigsRepo} && git pull && sudo nix-collect-garbage -d && sudo nixos-rebuild switch --flake .#";
        "update-dirty" = "cd ~/${cfg.nixConfigsRepo} && git add . && sudo nixos-rebuild switch --flake .#";
        "upgrade" = "cd ~/${cfg.nixConfigsRepo} && git pull && nix flake update --commit-lock-file && sudo nixos-rebuild switch --flake .# && git push";
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
      initExtra = ''
        cdr() {
            cd "${cfg.mainCodingRepo.path}/$@"
        }
        compdef '_files -W "${cfg.mainCodingRepo.path}" -/' cdr

        tfw() {
          cdr ${cfg.mainCodingRepo.workspaceDir}
          cargo test
          cargo fmt -- --config "comment_width=120,condense_wildcard_suffixes=false,format_code_in_doc_comments=true,format_macro_bodies=true,hex_literal_case=Upper,imports_granularity=One,normalize_doc_attributes=true,wrap_comments=true"
          cd -
        }
        ccw() {
          cdr ${cfg.mainCodingRepo.workspaceDir}
          cargo check 
          cd -
        }
        cucw() {
          cdr ${cfg.mainCodingRepo.workspaceDir}
          cargo clean
          cargo update
          cargo check
          cd -
        }
        cutfw() {
          cdr ${cfg.mainCodingRepo.workspaceDir}
          cargo clean
          cargo update
          cargo test
          cargo fmt -- --config "comment_width=120,condense_wildcard_suffixes=false,format_code_in_doc_comments=true,format_macro_bodies=true,hex_literal_case=Upper,imports_granularity=One,normalize_doc_attributes=true,wrap_comments=true"
          cd -
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
