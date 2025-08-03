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

# ghの補完を有効化
eval "$(gh completion -s zsh)"

. "$HOME/.local/bin/env"
alias yolo="claude --dangerously-skip-permissions"
alias ls='eza --icons --git --group-directories-first --all'
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

# fzf-tabでgit statusをファイル名の横に表示
zstyle ':fzf-tab:*' prefix ''
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:*' continuous-trigger 'tab'
zstyle ':fzf-tab:complete:*:*' fzf-preview-window 'right:50%:wrap'

# git状態を含む補完リストの生成
zstyle -e ':completion:*' list-colors 'reply=("${(@s.:.)LS_COLORS}")'
zstyle ':fzf-tab:complete:*' extra-opts --ansi

# fzf-tabでファイル名の横にgit statusを表示
zstyle ':fzf-tab:complete:*' fzf-search-display true

# git statusアイコンを追加する関数
_fzf_tab_apply_git_status() {
  local desc=$1
  local realpath=$2
  
  if [[ -f $realpath ]]; then
    local git_status=$(cd $(dirname $realpath) 2>/dev/null && git status --porcelain $(basename $realpath) 2>/dev/null | cut -c1-2)
    local status_icon=""
    case "$git_status" in
      *M*) status_icon=$'\033[1;33m● \033[0m' ;;  # 変更
      *A*) status_icon=$'\033[1;32m✚ \033[0m' ;;  # 追加
      *D*) status_icon=$'\033[1;31m✖ \033[0m' ;;  # 削除
      *R*) status_icon=$'\033[1;34m➜ \033[0m' ;;  # リネーム
      *"??"*) status_icon=$'\033[1;37m? \033[0m' ;;  # 未追跡
      *) status_icon="  " ;;
    esac
    echo -n "$status_icon$desc"
  elif [[ -d $realpath ]]; then
    echo -n "📁 $desc"
  else
    echo -n "$desc"
  fi
}

# 補完候補の表示を変換
zstyle ':fzf-tab:complete:*' query-string input
zstyle ':fzf-tab:complete:(cd|ls|nvim|vim|code|cat|bat):*' fzf-search-display true
zstyle ':fzf-tab:complete:(cd|ls|nvim|vim|code|cat|bat):*' display-transformer '_fzf_tab_apply_git_status $word $realpath'

# fzf-tabの詳細設定
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --git --git-ignore $realpath 2>/dev/null || ls -la $realpath'
zstyle ':fzf-tab:complete:*:*' fzf-preview \
  'if [[ -d $realpath ]]; then
    # ディレクトリの場合
    eza -la --color=always --git --git-ignore $realpath 2>/dev/null || ls -la $realpath
  elif [[ -f $realpath ]]; then
    # ファイルの場合はgit statusアイコン付きでプレビュー
    git_status=$(cd $(dirname $realpath) 2>/dev/null && git status --porcelain $(basename $realpath) 2>/dev/null | cut -c1-2)
    status_icon=""
    case "$git_status" in
      *M*) status_icon="● " ;;
      *A*) status_icon="✚ " ;;
      *D*) status_icon="✖ " ;;
      *R*) status_icon="➜ " ;;
      *"??"*) status_icon="? " ;;
    esac
    printf "\033[1;33m${status_icon}$(basename $realpath)\033[0m\n"
    file --mime $realpath 2>/dev/null
    echo "────────────────────────────────────────"
    # テキストファイルの場合は内容を表示
    if file --mime-type $realpath 2>/dev/null | grep -q "text/"; then
      bat --color=always --style=plain --line-range=:100 $realpath 2>/dev/null || head -100 $realpath
    else
      echo "Binary file"
    fi
  else
    # その他（コマンドなど）
    echo $realpath
  fi'
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

# ファイル操作系コマンドでファイル内容をプレビュー（git status付き）
zstyle ':fzf-tab:complete:(nvim|vim|code|cat|bat):*' fzf-preview \
  'if [[ -f $realpath ]]; then
    # ファイルの場合はgit statusを取得して表示
    git_status=$(cd $(dirname $realpath) 2>/dev/null && git status --porcelain $(basename $realpath) 2>/dev/null | cut -c1-2)
    status_icon=""
    case "$git_status" in
      *M*) status_icon="● " ;;  # 変更
      *A*) status_icon="✚ " ;;  # 追加
      *D*) status_icon="✖ " ;;  # 削除
      *R*) status_icon="➜ " ;;  # リネーム
      *"??"*) status_icon="? " ;;  # 未追跡
    esac
    printf "\033[1;33m${status_icon}$(basename $realpath)\033[0m\n"
    echo "────────────────────────────────────────"
    bat --color=always --style=numbers --line-range=:500 $realpath 2>/dev/null
  else
    # ディレクトリの場合はezaでgit status付きで表示
    eza -la --color=always --git --git-ignore $realpath 2>/dev/null || ls -la $realpath
  fi'

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

# manコマンドでマニュアルの冒頭を表示
zstyle ':fzf-tab:complete:man:*' fzf-preview \
  'man -P cat $word 2>/dev/null | head -20 || echo "No manual entry for $word"'

# sshコマンドでホスト情報を表示
zstyle ':fzf-tab:complete:ssh:*' fzf-preview \
  '[[ -f ~/.ssh/config ]] && grep -A 5 -B 1 "^Host $word" ~/.ssh/config 2>/dev/null || echo "Host: $word"'

# npmスクリプトのプレビュー
zstyle ':fzf-tab:complete:npm:*' fzf-preview \
  '[[ $words[2] == "run" && -f package.json ]] && cat package.json | jq -r ".scripts[\"$word\"] // \"Script not found\"" 2>/dev/null || echo "$word"'

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

# fzf-tabプレビューのデバッグ用関数
function test-fzf-preview() {
  local realpath="$1"
  if [[ -f $realpath ]]; then
    git_status=$(cd $(dirname $realpath) 2>/dev/null && git status --porcelain $(basename $realpath) 2>/dev/null | cut -c1-2)
    status_icon=""
    case "$git_status" in
      *M*) status_icon="● " ;;
      *A*) status_icon="✚ " ;;
      *D*) status_icon="✖ " ;;
      *R*) status_icon="➜ " ;;
      *"??"*) status_icon="? " ;;
    esac
    printf "\033[1;33m${status_icon}$(basename $realpath)\033[0m\n"
    echo "Git status: '$git_status'"
  fi
}

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
