function ghq_fzf
    set -l ghq_root (ghq root)
    set -l entries

    # ghq repos
    for p in (ghq list -p)
        set -l repo_name (string replace "$ghq_root/" "" $p)
        set -l session_name (string replace -r '^github\.com/' '' -- $repo_name)
        set -l window_name main
        set -a entries $p\t$session_name\t$session_name\t$window_name
    end


    set -l selected_line (printf '%s\n' $entries | fzf --height 40% --reverse --delimiter=\t --with-nth=2)
    if test -n "$selected_line"
        set -l selected_fields (string split \t -- $selected_line)
        set -l selected $selected_fields[1]
        set -l session_name $selected_fields[3]
        set -l window_name $selected_fields[4]
        __ghq_tmux_open "$selected" "$session_name" "$window_name"
    end
    commandline -f repaint
end
