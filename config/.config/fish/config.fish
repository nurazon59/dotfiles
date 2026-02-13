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
# Prompt
# -----------------------------------------------------------------------------
set -gx STARSHIP_CONFIG ~/.config/starship/starship.toml
starship init fish | source

set -x LANG en_US.UTF-8
set -x EDITOR nvim
set -x PAGER bat
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
# Abbreviations
# -----------------------------------------------------------------------------
if status --is-interactive
    abbr --add gco 'git checkout'
    abbr --add gcb 'git checkout -b'
end

# -----------------------------------------------------------------------------
# Key Bindings
# -----------------------------------------------------------------------------
fish_vi_key_bindings

bind \ck accept-autosuggestion
bind -M insert jj 'set fish_bind_mode default; commandline -f repaint'
bind -M insert \ck accept-autosuggestion

# -----------------------------------------------------------------------------
# Shell Configuration
# -----------------------------------------------------------------------------
set -g fish_history_size 10000

# TeX PATH
fish_add_path /Library/TeX/texbin

# pnpm
set -gx PNPM_HOME "$HOME/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
