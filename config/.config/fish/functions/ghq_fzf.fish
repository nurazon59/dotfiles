function ghq_fzf
    set -l ghq_root (ghq root)
    set -l paths
    set -l session_names
    set -l branches
    set -l max_len 0

    # ghq repos
    for p in (ghq list -p)
        set -l repo_name (string replace "$ghq_root/" "" $p)
        set -l session_name (string replace -r '^github\.com/' '' -- $repo_name)
        set -l branch (__git_head_branch $p)
        set -a paths $p
        set -a session_names $session_name
        set -a branches "$branch"
        set -l len (string length -- $session_name)
        test $len -gt $max_len; and set max_len $len
    end

    set -l entries
    for i in (seq (count $paths))
        set -l window_name main
        set -l display (string pad --right -w $max_len -- $session_names[$i])
        test -n "$branches[$i]"; and set display "$display  $branches[$i]"
        set -a entries $paths[$i]\t$display\t$session_names[$i]\t$window_name
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
