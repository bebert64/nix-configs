{
    enable = true;
    shellAliases = {
        "update" = "cd ~/configs/nixos && git pull && sudo nixos-rebuild switch --flake .#";
        "update-dirty" = "cd ~/configs/nixos && sudo nixos-rebuild switch --flake .#";
        "upgrade" = "cd ~/configs/nixos && git pull && nix flake update --commit-lock-file && sudo nixos-rebuild switch --flake .# && git push";
        "c" = "code .";
        "r" = "ranger --choosedir=$HOME/.rangerdir; cd \"$(cat $HOME/.rangerdir)\"; rm $HOME/.rangerdir";
        "datagrip-tunnel" = "ssh -L 5432:localhost:5432 charybdis";
    };
    history = {
        size = 200000;
        save = 200000;
        extended = true; # save timestamps
    };
    oh-my-zsh = {
        enable = true;
        plugins = [ "git" ];
        theme = "stockly";
        custom = "~/.config/oh-my-zsh-scripts";
    };
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    initExtra = ''
        cdr() {
            cd "$HOME/stockly/Main/$@"
        }
        compdef '_files -W "$HOME/stockly/Main" -/' cdr
    '';
    plugins = [
        {
            name = "stockly";
            src = ../../dotfiles/OhMyZsh;
            file = "stockly.zsh-theme";
        }
    ];
}
