# PATH設定
export PATH="$HOME/.local/bin:$PATH"

eval "$(sheldon source)"
eval "$(/Users/itsuki/.local/bin/mise activate zsh)"
eval "$(direnv hook zsh)"
eval "$(starship init zsh)"
eval "$(zoxide init zsh --hook prompt)"
export FPATH="<path_to_eza>/completions/zsh:$FPATH"
export PATH="$HOME/.local/share/aquaproj-aqua/pkgs/github_release/golang/go/1.22.0/go/bin:$PATH"

autoload -Uz compinit
compinit

. "$HOME/.local/bin/env"
alias yolo="claude --dangerously-skip-permissions"
alias ls='eza --icons --git --group-directories-first'
alias bat='nocorrect bat'
alias cat='bat --paging=never'
alias tree='eza --icons --git --group-directories-first --tree --git-ignore'

function gwadd() {
  if [ -z "$1" ]; then
    echo "Usage: gwadd <branch-name>"
    return 1
  fi

  branch="$1"
  dir="../${branch//\//-}"

  # すでに存在するブランチか確認
  if ! git show-ref --quiet "refs/heads/$branch"; then
    git branch "$branch"
  fi

  git worktree add "$dir" "$branch"
}

export LANG=en_US.UTF-8
export EDITOR='nvim'
export PAGER='less'
export LESS='-R'
export FZF_DEFAULT_OPTS='--height 40% --reverse'

setopt interactivecomments
setopt sharehistory
setopt histignorealldups
setopt autocd
setopt nocaseglob
unsetopt beep
setopt auto_menu
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups

zstyle ':fzf-tab:*' fzf-flags --layout=reverse --height=40%
zstyle ':completion:*' menu yes select  # 矢印で選択できるように

