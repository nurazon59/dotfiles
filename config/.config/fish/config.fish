# =============================================================================
# Fish Configuration
# =============================================================================

# -----------------------------------------------------------------------------
# PATH Configuration
# -----------------------------------------------------------------------------
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.local/share/mise/installs/tree-sitter/latest

# Repair stale universal fish_function_path values carried from other machines.
if set -q fish_function_path
    if not contains -- $__fish_config_dir/functions $fish_function_path
        set -eU fish_function_path
        set -g fish_function_path $__fish_config_dir/functions $__fish_sysconf_dir/functions $__fish_vendor_functionsdirs $__fish_data_dir/functions
    end
end

# -----------------------------------------------------------------------------
# Development Tools
# -----------------------------------------------------------------------------
$HOME/.local/bin/mise activate fish | source
direnv hook fish | source
zoxide init fish | source
fzf --fish | source

# -----------------------------------------------------------------------------
# Prompt
# -----------------------------------------------------------------------------
set -gx STARSHIP_CONFIG ~/.config/starship/starship.toml
starship init fish | source

set -x XDG_CONFIG_HOME ~/.config
set -x LANG en_US.UTF-8
set -x EDITOR nvim
set -x PAGER bat
set -x BAT_PAGER 'less -R'
set -x FZF_DEFAULT_OPTS '--height 40% --reverse --cycle --bind tab:down,btab:up'
set -x FZF_COMPLETION_OPTS '--select-1 --exit-0 --preview="bat -n --color=always {1} 2>/dev/null || lsd --color=always -a {1} 2>/dev/null" --preview-window=right:50%:wrap:border-left'

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
    abbr --add .. 'cd ..'
    abbr --add ... 'cd ../..'
    abbr --add .... 'cd ../../..'
    abbr --add ..... 'cd ../../../..'
    abbr --add gpr 'git pull'
    abbr --add gps 'git push'
    abbr --add gst 'git status'
    abbr --add lg 'lazygit'
end

# -----------------------------------------------------------------------------
# Key Bindings
# -----------------------------------------------------------------------------
fish_vi_key_bindings

bind \t fzf_tab_complete
bind \ck accept-autosuggestion
bind \cg ghq_fzf
bind -M insert \t fzf_tab_complete
bind -M insert jj 'set fish_bind_mode default; commandline -f repaint'
bind -M insert \ck accept-autosuggestion
bind -M insert \cg ghq_fzf

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

git wt --init fish | source
