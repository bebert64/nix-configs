{ config-name } :

{
    enable = true;
    shellAliases = {
        "update" = "cd ~/nix-configs/home-manager && git pull && home-manager switch --flake .#${config-name}";
        "update-dirty" = "cd ~/nix-configs/home-manager && home-manager switch --flake .#${config-name}";
        "upgrade" = "cd ~/nix-configs/home-manager && git pull && nix flake update --commit-lock-file && home-manager switch --flake .#${config-name} && git push";
        "c" = "code .";
        "r" = "ranger --choosedir=$HOME/.rangerdir; cd \"$(cat $HOME/.rangerdir)\"; rm $HOME/.rangerdir";
        "wke1" = "i3-msg workspace \"\\\" \\\"\"";
        "mount-NAS" = "mount nas.capucina.house:/volume1/NAS";
        "mount-Stockly" = "sshfs charybdis:/home/romain/Stockly/Main $HOME/Mnt/Charybdis";
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
    syntaxHighlighting.enable = true;
    initExtra = ''
        cdr() {
            cd "$HOME/stockly/Main/$@"
        }
        compdef '_files -W "$HOME/stockly/Main" -/' cdr
        path+="$HOME/.cargo/bin"
        eval "$(direnv hook zsh)"
	    source "$HOME/.profile"

        if [[ "$(tty)" == '/dev/tty1' ]]; then
            exec startx
        fi
    '';
    plugins = [
        {
            name = "stockly";
            src = ../../dotfiles/OhMyZsh;
            file = "stockly.zsh-theme";
        }
    ];
}
