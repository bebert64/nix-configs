# Stockly theme
# Configuration
ZSH_THEME_USERNAME_COLOR="%F{033}"
ZSH_THEME_SEPARATOR_COLOR="%F{202}"
ZSH_THEME_HOSTNAME_COLOR="%F{003}"
ZSH_THEME_LOCATION_COLOR="%F{105}"
ZSH_GIT_COLOR="%F{070}"
ZSH_THEME_GIT_PROMPT_STAGED_COLOR="%F{003}"
ZSH_THEME_GIT_PROMPT_UNSTAGED_COLOR="%F{039}"
ZSH_THEME_GIT_PROMPT_STASHED_COLOR="%F{129}"
ZSH_THEME_NIX_SHELL_COLOR="%F{027}"  # Blue color for nix-shell indicator

if [ "x$OH_MY_ZSH_HG" = "x" ]; then
    OH_MY_ZSH_HG="hg"
fi

function virtualenv_info() {
  [ $VIRTUAL_ENV ] && echo '('`basename $VIRTUAL_ENV`') '
}

function nix_shell_info() {
  if [[ -n "$IN_NIX_SHELL" ]]; then
    echo "%F{027}(nix-shell)%{$reset_color%} "
  fi
}

function hg_prompt_info() {
    $OH_MY_ZSH_HG prompt --angle-brackets "\
<(%{$fg[magenta]%}<branch>%{$reset_color%})>\
< at %{$fg[yellow]%}<tags|%{$reset_color%}, %{$fg[yellow]%}>%{$reset_color%}>\
%{$fg[green]%}<status|modified|unknown><update>%{$reset_color%}<
patches: <patches|join( → )|pre_applied(%{$fg[yellow]%})|post_applied(%{$reset_color%})|pre_unapplied(%{$fg_bold[black]%})|post_unapplied(%{$reset_color%})>>" 2>/dev/null
}

function box_name() {
  [ -f ~/.box-name ] && cat ~/.box-name || bash -c 'echo $HOSTNAME' 
}

function prompt_char() {
  [[ -n "$IN_NIX_SHELL" ]] && echo '❄' && return  # Nix snowflake
  git branch >/dev/null 2>/dev/null && echo '±' && return
  hg root >/dev/null 2>/dev/null && echo '☿' && return
  echo '$'
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
function status() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="💥%{$ZSH_THEME_SEPARATOR_COLOR%}[%{%F{red}%}$RETVAL%{$reset_color%}%{$ZSH_THEME_SEPARATOR_COLOR%}]"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}♔ "
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙ "

  [[ -n "$symbols" ]] && echo "${symbols}%{$reset_color%}"
}

function username() {
  if [[ -n "$IN_NIX_SHELL" ]]; then
    echo "$ZSH_THEME_NIX_SHELL_COLOR%n%{$reset_color%}"
  else
    echo "$ZSH_THEME_USERNAME_COLOR%n%{$reset_color%}"
  fi
}
function computer() {
  echo "$ZSH_THEME_SEPARATOR_COLOR@$ZSH_THEME_HOSTNAME_COLOR$(box_name)%{$reset_color%}"
}
function location () {
  local CURRENT_DIR=""
  local NB_CHARS=$(command echo ${PWD/#$HOME/~} 2>/dev/null | wc -c)
  if [[ $(command git rev-parse --short HEAD 2> /dev/null) ]];then
    if [[ $NB_CHARS -gt 50 ]];then
      CURRENT_DIR=${${PWD/#$HOME/~}:$(dirname $(git rev-parse --show-toplevel) | wc -c)}
      if [[ $(command echo $CURRENT_DIR 2>/dev/null | wc -c) -gt 50 ]];then
        CURRENT_DIR="$(basename $(git rev-parse --show-toplevel))/.../${PWD##*/}"
      fi
    else
      CURRENT_DIR="${PWD/#$HOME/~}"
    fi
  else
    if [[ $NB_CHARS -gt 100 ]];then
      CURRENT_DIR="${PWD##*/}"
    else
      CURRENT_DIR="${PWD/#$HOME/~}"
    fi
  fi
  echo "$ZSH_THEME_SEPARATOR_COLOR:$ZSH_THEME_LOCATION_COLOR$CURRENT_DIR%{$reset_color%}"
}
function git_infos() {
  echo $(git_prompt_info)
}
function invite() {
  echo "%F{001}$(prompt_char)%{$reset_color%}"
}
function build_prompt() {
  RETVAL=$?
  echo "
$(nix_shell_info)$(status)$(username)$(computer)$(location)$(git_infos)
$(invite)"
}

PROMPT='$(build_prompt)'

ZSH_GIT_REMOTE_NAME=origin
ZSH_THEME_GIT_PROMPT_PREFIX="$ZSH_THEME_SEPARATOR_COLOR(%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="$ZSH_THEME_SEPARATOR_COLOR)%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_NO_REMOTE="$ZSH_GIT_COLOR-%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE="%F{003}\uE0A0%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_EQUAL_REMOTE="$ZSH_GIT_COLOR\uE0A0%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE="%F{005}\uE0A0%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_STASHED="✯"
ZSH_THEME_GIT_PROMPT_UNTRACKED="?"
ZSH_THEME_GIT_PROMPT_DELETED="!"
ZSH_THEME_GIT_PROMPT_MODIFIED="∆"
ZSH_THEME_GIT_PROMPT_ADDED="+"
ZSH_THEME_GIT_PROMPT_RENAMED="⇢ "
ZSH_THEME_GIT_PROMPT_CLEAN=""

local return_status="%{$fg[red]%}%*%{$reset_color%}"
RPROMPT='${return_status}%{$reset_color%}'
RPS1='${return_status}%{$reset_color%}'
