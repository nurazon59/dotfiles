# PATH設定
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.local/share/mise/installs/tree-sitter/latest
fish_add_path /Library/TeX/texbin

# mise, direnv初期化
$HOME/.local/bin/mise activate fish | source
direnv hook fish | source

# Starship configuration (無効化)
# set -x STARSHIP_CONFIG "$HOME/.config/starship/starship.toml"
# starship init fish | source

# zoxideはプロンプトフックなしで初期化
zoxide init fish | source

# gh補完を有効化
gh completion -s fish | source

# docker補完を有効化  
docker completion fish | source

# 環境変数読み込み
source "$HOME/.local/bin/env"

# エイリアス設定
alias yolo="claude --dangerously-skip-permissions"
alias ls='lsd --icon always --git --group-directories-first --all'
alias bat='bat'
alias cat='bat --paging=never'
alias tree='lsd --icon always --git --group-directories-first --tree'
alias less='bat --paging=always'

# 環境変数
set -x LANG en_US.UTF-8
set -x EDITOR 'nvim'
set -x PAGER 'bat'
set -x BAT_PAGER 'less -R'
set -x FZF_DEFAULT_OPTS '--height 40% --reverse'

# キーバインディング設定
bind \cg ghq-fzf
bind \ck accept-autosuggestion

# 履歴設定
set -U fish_history_size 10000

# Git prompt設定
set -g __fish_git_prompt_showdirtystate 1
set -g __fish_git_prompt_showstashstate 1
set -g __fish_git_prompt_showuntrackedfiles 1
set -g __fish_git_prompt_showupstream 1
set -g __fish_git_prompt_show_informative_status 1
set -g __fish_git_prompt_showcolorhints 1

# viモードを使用する場合（オプション）
fish_vi_key_bindings

# starshipを完全に無効化してネイティブプロンプトを使用
if functions -q fish_prompt
    functions -e fish_prompt
end
source ~/.config/fish/functions/fish_prompt.fish

if functions -q fish_right_prompt  
    functions -e fish_right_prompt
end
source ~/.config/fish/functions/fish_right_prompt.fish
