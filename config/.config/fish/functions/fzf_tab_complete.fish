function fzf_tab_complete
    set -l buffer (commandline -b)
    set -l token (commandline -t)

    if test -z "$buffer"
        commandline -f complete
        return
    end

    set -l completions (complete -C -- "$buffer")
    set -l count (count $completions)

    if test $count -eq 0
        return
    end

    if test $count -eq 1
        commandline -rt -- (string split \t -- $completions[1])[1]
        commandline -f repaint
        return
    end

    set -l pick (printf '%s\n' $completions | fzf --height=40% --reverse --select-1 --exit-0 --query="$token" --delimiter=\t --with-nth=1,2)
    if test -n "$pick"
        commandline -rt -- (string split \t -- $pick)[1]
    end
    commandline -f repaint
end
