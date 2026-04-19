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

    # worktrees (git wt経由で取得、スラッシュ入りブランチにも対応)
    for repo in (ghq list -p)
        test -d "$repo/.wt"; or continue
        set -l repo_name (string replace "$ghq_root/" "" $repo)
        set -l session_name (string replace -r '^github\.com/' '' -- $repo_name)
        for wt_line in (git -C $repo worktree list --porcelain 2>/dev/null | string match 'worktree *')
            set -l wt_path (string replace 'worktree ' '' $wt_line)
            # メインworktreeはghq listで既に含まれるのでスキップ
            test "$wt_path" = "$repo"; and continue
            set -l rel (string replace "$repo/.wt/" "" $wt_path)
            set -a entries $wt_path\t$session_name:$rel\t$session_name\t$rel
        end
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
