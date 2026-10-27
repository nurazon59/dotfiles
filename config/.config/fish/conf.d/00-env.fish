set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx TAPLO_CONFIG "$XDG_CONFIG_HOME/taplo/taplo.toml"
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_CACHE_HOME "$HOME/.cache"
set -gx npm_config_cache "$XDG_CACHE_HOME/npm"
set -gx pnpm_config_store_dir "$XDG_DATA_HOME/pnpm/store"
set -gx GOCACHE "$XDG_CACHE_HOME/go-build"
set -gx GOMODCACHE "$XDG_CACHE_HOME/go/mod"
set -gx PIP_CACHE_DIR "$XDG_CACHE_HOME/pip"
set -gx BUN_INSTALL_CACHE_DIR "$XDG_CACHE_HOME/bun/install/cache"
set -gx PI_CODING_AGENT_DIR "$XDG_CONFIG_HOME/pi"
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

set -gx DOCKER_HOST "unix://$HOME/.config/colima/default/docker.sock"
