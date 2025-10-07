# =============================================================================
# Fish Configuration
# =============================================================================

# -----------------------------------------------------------------------------
# PATH Configuration
# -----------------------------------------------------------------------------
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.local/share/mise/installs/tree-sitter/latest

# -----------------------------------------------------------------------------
# Development Tools
# -----------------------------------------------------------------------------
$HOME/.local/bin/mise activate fish | source
direnv hook fish | source
zoxide init fish | source

# -----------------------------------------------------------------------------
# Shell Completions
# -----------------------------------------------------------------------------
gh completion -s fish | source
docker completion fish | source

# -----------------------------------------------------------------------------
# Environment Variables
# -----------------------------------------------------------------------------
source "$HOME/.local/bin/env"

set -x LANG en_US.UTF-8
set -x EDITOR 'nvim'
set -x PAGER 'bat'
set -x BAT_PAGER 'less -R'
set -x FZF_DEFAULT_OPTS '--height 40% --reverse'

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------
alias yolo="claude --dangerously-skip-permissions"
alias ls='lsd --icon always --git --group-directories-first --all'
alias bat='bat'
alias cat='bat --paging=never'
alias tree='lsd --icon always --git --group-directories-first --tree'
alias less='bat --paging=always'

# -----------------------------------------------------------------------------
# Key Bindings
# -----------------------------------------------------------------------------
fish_vi_key_bindings

bind \cg ghq-fzf
bind \ck accept-autosuggestion
bind -M insert jj 'set fish_bind_mode default; commandline -f repaint'
bind -M insert \ck accept-autosuggestion

# -----------------------------------------------------------------------------
# Shell Configuration
# -----------------------------------------------------------------------------
set -U fish_history_size 10000

# -----------------------------------------------------------------------------
# Git Prompt Configuration
# -----------------------------------------------------------------------------
set -g __fish_git_prompt_showdirtystate 1
set -g __fish_git_prompt_showstashstate 1
set -g __fish_git_prompt_showuntrackedfiles 1
set -g __fish_git_prompt_showupstream 1
set -g __fish_git_prompt_show_informative_status 1
set -g __fish_git_prompt_showcolorhints 1

# -----------------------------------------------------------------------------
# Theme Configuration
# -----------------------------------------------------------------------------
source ~/.config/fish/functions/catppuccin_frappe.fish
catppuccin_frappe

