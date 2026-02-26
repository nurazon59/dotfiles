function __update_tmux_cwd --on-variable PWD
    if set -q TMUX
        command tmux rename-window (basename $PWD)
        command tmux set-option -qp @cwd "$PWD"
        command tmux refresh-client -S
    end
end
if set -q TMUX
    __update_tmux_cwd
end
