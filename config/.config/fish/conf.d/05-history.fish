set -g fish_history_size 10000

function __fish_set_history --on-variable PWD
    set -g fish_history (string escape --style=var -- $PWD)
end

__fish_set_history
