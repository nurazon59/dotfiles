# PATH設定
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/share/mise/installs/tree-sitter/latest:$PATH"
export PATH="/Library/TeX/texbin:$PATH"

eval "$(sheldon source)"
eval "$(${HOME}/.local/bin/mise activate zsh)"
eval "$(direnv hook zsh)"

# Starship configuration
export STARSHIP_CONFIG="${HOME}/.config/starship/starship.toml"
eval "$(starship init zsh)"
eval "$(zoxide init zsh --hook prompt)"

autoload -Uz compinit
compinit

# ghの補完を有効化
eval "$(gh completion -s zsh)"

# dockerの補完を有効化
eval "$(docker completion zsh)"


alias yolo="claude --dangerously-skip-permissions"
alias ls='lsd --icon always --git --group-directories-first --all'
alias bat='nocorrect bat'
alias cat='bat --paging=never'
alias tree='lsd --icon always --git --group-directories-first --tree'

# git log をデフォルトでreverse表示
git() {
  if [[ "$1" == "log" ]]; then
    command git log --reverse "${@:2}"
  else
    command git "$@"
  fi
}




export LANG=en_US.UTF-8
export EDITOR='nvim'
export PAGER='bat'
export BAT_PAGER='less -R'
alias less='bat --paging=always'
export FZF_DEFAULT_OPTS='--height 40% --reverse'

setopt interactivecomments
setopt autocd
setopt nocaseglob
unsetopt beep
setopt auto_menu
setopt auto_pushd
setopt pushd_ignore_dups

zstyle ':fzf-tab:*' fzf-flags --layout=reverse --height=40%
zstyle ':completion:*' menu yes select  # 矢印で選択できるように

# fzf-tabの詳細設定
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd -1 --color=always $realpath'

# Git関連の補完で色付きプレビュー表示
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview \
  'git diff --color=always -- $realpath 2>/dev/null || git ls-files --error-unmatch $realpath 2>/dev/null && echo "$realpath (tracked)" || echo "$realpath (untracked)"'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
  'case "$group" in
    "modified file") git diff --color=always -- $realpath 2>/dev/null ;;
    "recent commit object name") git show --color=always $word 2>/dev/null ;;
    "branch") git log --color=always --oneline -n 10 $word 2>/dev/null ;;
    *) echo $word ;;
  esac'

# ファイル操作系コマンドでファイル内容をプレビュー
zstyle ':fzf-tab:complete:(nvim|vim|code|cat|bat):*' fzf-preview \
  '[[ -f $realpath ]] && bat --color=always --style=numbers --line-range=:500 $realpath 2>/dev/null || lsd -la --color=always $realpath 2>/dev/null'



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

