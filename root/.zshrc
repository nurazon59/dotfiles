# PATH設定
export PATH="$HOME/.local/bin:$PATH"

eval "$(sheldon source)"
eval "$(/Users/itsuki54/.local/bin/mise activate zsh)"
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

# ghqでリポジトリを作成する関数
function gcr() {
  local repo_name=$1
  shift
  
  if [[ -z "$repo_name" ]]; then
    echo "使い方: gcr <repository-name> [gh repo create options]"
    return 1
  fi
  
  # GitHubユーザー名を取得
  local github_user=$(gh api user --jq .login)
  
  # ghqのパスを作成
  local repo_path="$(ghq root)/github.com/$github_user/$repo_name"
  
  # GitHubにリポジトリ作成（デフォルトでプライベート、READMEとMITライセンス追加）
  gh repo create "$repo_name" --private --add-readme --license mit "$@"
  
  # ghqでクローン
  ghq get "$github_user/$repo_name"
  
  # 作成したディレクトリに移動
  cd "$repo_path"
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

_comp_options+=(globdots)

HISTSIZE=10000    # メモリに保存される履歴の件数
SAVEHIST=1000000  # 保存される履歴の件数
# https://github.com/rothgar/mastering-zsh/blob/921766e642bcf02d0f1be8fc57d0159a867299b0/docs/config/history.md
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt HIST_VERIFY               # Do not execute immediately upon history expansion.
setopt APPEND_HISTORY            # append to history file
setopt HIST_NO_STORE             # Don't store history commands

bindkey '^K' autosuggest-accept
