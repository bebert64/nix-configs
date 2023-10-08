{
    enable = true;
    shellAliases = {
        "update" = "cd ~/nix-configs/nixos && git pull && sudo nixos-rebuild switch --flake .#";
        "update-dirty" = "cd ~/nix-configs/nixos && sudo nixos-rebuild switch --flake .#";
        "upgrade" = "cd ~/nix-configs/nixos && git pull && nix flake update --commit-lock-file && sudo nixos-rebuild switch --flake .# && git push";
        "c" = "code .";
        "r" = "ranger --choosedir=$HOME/.rangerdir; cd \"$(cat $HOME/.rangerdir)\"; rm $HOME/.rangerdir";
        "wke1" = "i3-msg workspace \"\\\" \\\"\"";
        "mount-NAS" = "mount nas.capucina:volume1/NAS";
    };
    history = {
        size = 200000;
        save = 200000;
        extended = true; # save timestamps
    };
    oh-my-zsh = {
        enable = true;
    };
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
    initExtra = ''
        cdr() {
            cd "$HOME/stockly/Main/$@"
        }
        compdef '_files -W "$HOME/stockly/Main" -/' cdr
        path+="$HOME/.cargo/bin"
        eval "$(direnv hook zsh)"
    '';
    plugins = [
        {
            name = "stockly";
            src = ../../dotfiles/OhMyZsh;
            file = "stockly.zsh-theme";
        }
        {
            name = "git";
            src = ../../dotfiles/OhMyZsh;
            file = "git.zsh";
        }
    ];
}
