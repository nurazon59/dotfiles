# PATH設定
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/share/mise/installs/tree-sitter/latest:$PATH"
export PATH="/Library/TeX/texbin:$PATH"

eval "$(sheldon source)"
eval "$(${HOME}/.local/bin/mise activate zsh)"
eval "$(direnv hook zsh)"
eval "$(starship init zsh)"
eval "$(zoxide init zsh --hook prompt)"
export FPATH="<path_to_eza>/completions/zsh:$FPATH"
export PATH="$HOME/.local/share/aquaproj-aqua/pkgs/github_release/golang/go/1.22.0/go/bin:$PATH"

autoload -Uz compinit
compinit

# ghの補完を有効化
eval "$(gh completion -s zsh)"

. "$HOME/.local/bin/env"
alias yolo="claude --dangerously-skip-permissions"
alias ls='eza --icons --git --group-directories-first --all'
alias bat='nocorrect bat'
alias cat='bat --paging=never'
alias tree='eza --icons --git --group-directories-first --tree --git-ignore'

# git log をデフォルトでreverse表示
git() {
  if [[ "$1" == "log" ]]; then
    command git log --reverse "${@:2}"
  else
    command git "$@"
  fi
}

function wt() {
  if [ -z "$1" ]; then
    echo "Usage: wt <branch-name>"
    return 1
  fi

  # nurazon59/プレフィックスを追加（すでに付いている場合は重複しない）
  if [[ "$1" == nurazon59/* ]]; then
    branch="$1"
  else
    branch="nurazon59/$1"
  fi
  
  dir="../${branch//\//-}"

  # すでに存在するブランチか確認
  if ! git show-ref --quiet "refs/heads/$branch"; then
    git branch "$branch"
  fi

  git worktree add "$dir" "$branch"
}

# ghqとfzfでリポジトリ移動
function ghq-fzf() {
  local src=$(ghq list | fzf --preview "bat --color=always --style=header,grid --line-range :80 $(ghq root)/{}/README.*" --bind="tab:down,btab:up")
  if [ -n "$src" ]; then
    BUFFER="cd $(ghq root)/$src"
    zle accept-line
  fi
  zle -R -c
}
zle -N ghq-fzf
bindkey '^g' ghq-fzf

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
export PAGER='bat'
export BAT_PAGER='less -R'
alias less='bat --paging=always'
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

# fzf-tabの詳細設定
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:*:*' fzf-preview 'less ${(Q)realpath}'
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'

# ghコマンドの補完でヘルプを表示
zstyle ':fzf-tab:complete:gh:*' fzf-preview 'gh help $word 2>/dev/null || echo "No help available"'
zstyle ':fzf-tab:complete:gh-*:*' fzf-preview 'gh $word --help 2>/dev/null || echo "No help available"'

# Git関連の補完で色付きプレビュー表示
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview \
  'git diff --color=always -- $realpath 2>/dev/null || git ls-files --error-unmatch $realpath 2>/dev/null && echo "$realpath (tracked)" || echo "$realpath (untracked)"'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
  'case "$group" in
    "modified file") git diff --color=always -- $realpath ;;
    "recent commit object name") git show --color=always $word ;;
    "branch") git log --color=always --oneline -n 10 $word ;;
    *) echo $word ;;
  esac'

# ファイル操作系コマンドでファイル内容をプレビュー
zstyle ':fzf-tab:complete:(nvim|vim|code|cat|bat):*' fzf-preview \
  '[[ -f $realpath ]] && bat --color=always --style=numbers --line-range=:500 $realpath 2>/dev/null || eza -la --color=always $realpath 2>/dev/null'

# killコマンドでプロセス情報を表示
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview \
  '[[ $IPREFIX =~ "^-" ]] && echo "signal: $word" || ps aux | grep -E "^[^ ]+ +$word"'

# dockerコマンドのプレビュー
zstyle ':fzf-tab:complete:docker:argument-1' fzf-preview \
  'docker help $word 2>/dev/null | head -20'
zstyle ':fzf-tab:complete:docker-container-*:*' fzf-preview \
  'docker container inspect $word 2>/dev/null | jq ".[0] | {Name, State, Image}" || echo "Container not found"'
zstyle ':fzf-tab:complete:docker-image-*:*' fzf-preview \
  'docker image inspect $word 2>/dev/null | jq ".[0] | {RepoTags, Size}" || echo "Image not found"'

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

# brew installの個別実行を禁止
brew() {
  if [[ "$1" == "install" ]]; then
    echo "エラー: 'brew install'は禁止されています。"
    echo "代わりに'brew bundle'を使用してください。"
    echo "Brewfileに追加してから'brew bundle'を実行してください。"
    return 1
  else
    command brew "$@"
  fi
}

# npmの使用を制限（publishとloginのみ許可）
npm() {
  if [[ "$1" == "publish" || "$1" == "login" ]]; then
    command npm "$@"
  else
    echo "エラー: npmは禁止されています。代わりにpnpmを使用してください。"
    echo "ただし、'npm publish'と'npm login'は許可されています。"
    return 1
  fi
}

# pipの使用を禁止し、uvを推奨
pip() {
  echo "エラー: pipは禁止されています。代わりにuvを使用してください。"
  return 1
}

# pip3も同様に禁止
pip3() {
  echo "エラー: pip3は禁止されています。代わりにuvを使用してください。"
  return 1
}

# venvとvirtualenvの使用を禁止し、uv venvを推奨
venv() {
  echo "エラー: venvは禁止されています。代わりに'uv venv'を使用してください。"
  return 1
}

virtualenv() {
  echo "エラー: virtualenvは禁止されています。代わりに'uv venv'を使用してください。"
  return 1
}

# pythonコマンドで仮想環境作成を試みた場合も警告
python() {
  if [[ "$1" == "-m" && "$2" == "venv" ]]; then
    echo "エラー: 'python -m venv'は禁止されています。代わりに'uv venv'を使用してください。"
    return 1
  else
    command python "$@"
  fi
}

python3() {
  if [[ "$1" == "-m" && "$2" == "venv" ]]; then
    echo "エラー: 'python3 -m venv'は禁止されています。代わりに'uv venv'を使用してください。"
    return 1
  else
    command python3 "$@"
  fi
}
# find のラッパー
find() {
  # 引数がない場合は fd をそのまま実行
  if [ $# -eq 0 ]; then
    command fd
    return
  fi

  # -name を使った検索を fd にマッピング
  if [[ "$1" == "-name" && -n "$2" ]]; then
    pattern="$2"
    shift 2
    command fd "$pattern" "$@"
    return
  fi

  # -type f / -type d を fd にマッピング
  if [[ "$1" == "-type" && "$2" == "f" ]]; then
    shift 2
    command fd -t f "$@"
    return
  elif [[ "$1" == "-type" && "$2" == "d" ]]; then
    shift 2
    command fd -t d "$@"
    return
  fi

  # それ以外はオリジナル find を実行
  command find "$@"
}

