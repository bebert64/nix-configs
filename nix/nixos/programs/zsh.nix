{
  enable = true;
  shellAliases = {
    "upgrade" = "cd ~/nix-config && nix flake update && apply-nix";
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
  autosuggestion.enable = true;
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
      src = ../../../dotfiles/OhMyZsh;
      file = "stockly.zsh-theme";
    }
    {
      name = "git";
      src = ../../../dotfiles/OhMyZsh;
      file = "git.zsh";
    }
  ];
}
