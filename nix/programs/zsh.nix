{ additional-aliases }:
{
  enable = true;
  shellAliases = {
    "c" = "code .";
    "wke1" = "i3-msg workspace \"\\\" \\\"\"";
    "de" = "yt-dlp -f 720p_HD";
  } // additional-aliases;
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
    {
      name = "git";
      src = ../../dotfiles/OhMyZsh;
      file = "git.zsh";
    }
  ];
}
