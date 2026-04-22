set -x XDG_CONFIG_HOME ~/.config
set -x LANG en_US.UTF-8
set -x EDITOR nvim
set -x PAGER bat
set -x BAT_PAGER 'less -R'
set -x FZF_DEFAULT_OPTS '--height 40% --reverse --cycle --bind tab:down,btab:up'
set -x FZF_COMPLETION_OPTS '--select-1 --exit-0 --preview="bat -n --color=always {1} 2>/dev/null || lsd --color=always -a {1} 2>/dev/null" --preview-window=right:50%:wrap:border-left'
set -gx STARSHIP_CONFIG ~/.config/starship/starship.toml
set -x CLAUDE_CONFIG_DIR "$XDG_CONFIG_HOME/claude"
set -gx RIPGREP_CONFIG_PATH "$HOME/.config/ripgrep/ripgreprc"
set -gx CODEX_HOME "$HOME/.config/codex"
set -g fish_history_size 10000
