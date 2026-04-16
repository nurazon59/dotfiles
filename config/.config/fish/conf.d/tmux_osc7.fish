function __update_tmux_cwd --on-variable PWD
    if set -q TMUX
        set -l window_name (command git -C "$PWD" symbolic-ref --quiet --short HEAD 2>/dev/null)
        test -n "$window_name"; or set window_name (basename "$PWD")
        command tmux rename-window "$window_name"
        command tmux set-option -qp @cwd "$PWD"
        command tmux refresh-client -S
    end
end
if set -q TMUX
    __update_tmux_cwd
end
