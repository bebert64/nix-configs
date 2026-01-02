# Zsh configuration
# Generated from raspi profile

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=200000
SAVEHIST=200000
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="stockly"

plugins=(
  git
)

source $ZSH/oh-my-zsh.sh

# Enable zsh-autosuggestions
if [ -f ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Enable zsh-syntax-highlighting
if [ -f ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Custom theme and git functions
if [ -f ~/.oh-my-zsh/themes/stockly.zsh-theme ]; then
  source ~/.oh-my-zsh/themes/stockly.zsh-theme
fi

if [ -f ~/.oh-my-zsh/custom/git.zsh ]; then
  source ~/.oh-my-zsh/custom/git.zsh
fi

# Shell aliases
alias wke1="i3-msg workspace 11:󰸉"
alias wke2="i3-msg workspace 12:󰸉"
alias cargo2nix="cdr && cargo2nix -ol && cd -"

# Systemd
alias jc="journalctl -xefu"
alias jcb="jc backup --user"
alias jcc="jc comfyui"
alias jcgt="jc guitar-tutorials --user"
alias jcg="jc guitar --user"
alias jcm="jc media --user"
alias jcs="jc shortcuts --user"
alias jcwd="jc wallpapers-download --user"
alias ss="systemctl status"
alias ssc="ss comfyui"
alias ssg="ss guitar --user"
alias ssm="ss media --user"
alias ssq="ss qbittorrent --user"
alias sss="ss stash --user"

# Nix (may not be applicable on non-NixOS)
alias nix-shell="nix-shell --run zsh"

# Cargo
formatOptions="comment_width=120,condense_wildcard_suffixes=false,format_code_in_doc_comments=true,format_macro_bodies=true,hex_literal_case=Upper,imports_granularity=One,normalize_doc_attributes=true,wrap_comments=true"
alias tfw="run-in-code-repo 'cargo fmt -- --config \"${formatOptions}\" && cargo test'"
alias ccw="run-in-code-repo 'cargo check'"
alias cccw="run-in-code-repo 'cargo clean && cargo check'"
alias cctfw="run-in-code-repo 'cargo fmt -- --config \"${formatOptions}\" && cargo clean && cargo test'"

# Helpers
nixConfigsRepo="${NIX_CONFIGS_REPO:-nix-configs}"
mainCodingRepo="${MAIN_CODING_REPO:-code}"

run-in-nix-repo() {
  cd ~/${nixConfigsRepo}
  git pull || return 1
  (eval "$*")
  cd -
}

run-in-nix-repo-dirty() {
  cd ~/${nixConfigsRepo}
  (eval "$*")
  cd -
}

run-in-code-repo() {
  cd ~/${mainCodingRepo}
  (eval "$*")
  cd -
}

# Cdr and completion
compdef '_files -W "$HOME/${mainCodingRepo}" -/' cdr
cdr() {
  cd "$HOME/${mainCodingRepo}/$@"
}

# Other utilities
psg() {
  ps aux | grep $1 | grep -v psg | grep -v grep
}

run() {
  command -v nix > /dev/null && nix run "nixpkgs#$1" -- "${@:2}" || $1 "${@:2}"
}

sync-wallpapers() {
  rsync -avh --exclude "Fond pour téléphone" $HOME/mnt/NAS/Wallpapers/ ~/wallpapers
  rsync -avh ~/wallpapers/ $HOME/mnt/NAS/Wallpapers
}

wol-ssh() {
  ssh raspi "wol-by-db $2"
  while ssh raspi "! ping -c1 $3 &> /dev/null"; do
    echo "$1 is not responding"
    sleep 1
  done
  ssh $1 -t "xset -display :0.0 dpms force off; zsh -i"
}

wb() {
  wol-ssh bureau D4:3D:7E:D8:C3:95 192.168.1.4
}

ws() {
  wol-ssh salon 74:56:3c:36:71:db 192.168.1.6
}

# Add cargo bin to path
export PATH="$HOME/.cargo/bin:$PATH"

# Direnv hook
if command -v direnv > /dev/null; then
  eval "$(direnv hook zsh)"
fi
