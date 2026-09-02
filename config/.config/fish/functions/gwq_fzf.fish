function gwq_fzf
    command git rev-parse --is-inside-work-tree >/dev/null 2>&1; or return

    set -l ghq_root (ghq root 2>/dev/null)
    set -l git_common_dir (command git rev-parse --path-format=absolute --git-common-dir)
    set -l main_worktree (string replace -r '/\.git/?$' '' -- $git_common_dir)
    set -l repo_name (string replace "$ghq_root/" '' -- $main_worktree)
    # worktreeでもメインリポジトリと同じtmuxセッションに集約する
    set -l session_name (string replace -r '^github\.com/' '' -- $repo_name)

    set -l paths
    set -l branches
    set -l is_mains
    set -l max_len 0
    set -l is_first 1
    set -l wt_path
    set -l wt_head

    for line in (command git worktree list --porcelain 2>/dev/null)
        switch $line
            case 'worktree *'
                set wt_path (string sub -s 10 -- $line)
            case 'HEAD *'
                set wt_head (string sub -s 6 -l 7 -- $line)
            case 'branch *' detached
                set -l branch (string replace -r '^branch refs/heads/' '' -- $line)
                test "$line" = detached; and set branch "($wt_head)"

                set -a paths $wt_path
                set -a branches $branch
                # porcelain の最初のエントリがメインworktree
                if test $is_first -eq 1
                    set -a is_mains true
                    set is_first 0
                else
                    set -a is_mains false
                end

                set -l len (string length -- $branch)
                test $len -gt $max_len; and set max_len $len
        end
    end

    if test (count $paths) -eq 0
        commandline -f repaint
        return
    end

    set -l entries
    for i in (seq (count $paths))
        set -l mark '  '
        test "$is_mains[$i]" = true; and set mark '● '
        set -l branch (string pad --right -w $max_len -- $branches[$i])
        set -l short_path (string replace -- "$HOME" '~' $paths[$i])
        set -a entries $paths[$i]\t"$mark$branch  $short_path"\t$branches[$i]
    end

    set -l selected_line (printf '%s\n' $entries | fzf --height 40% --reverse --delimiter=\t --with-nth=2)
    if test -n "$selected_line"
        set -l selected_fields (string split \t -- $selected_line)
        __ghq_tmux_open "$selected_fields[1]" "$session_name" "$selected_fields[3]"
    end
    commandline -f repaint
end
