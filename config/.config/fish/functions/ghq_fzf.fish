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
        set -l session_id

        for line in (tmux list-sessions -F "#{session_id}|#{session_name}" 2>/dev/null)
            set -l session_fields (string split --max 1 '|' -- $line)
            if test "$session_fields[2]" = "$session_name"
                set session_id $session_fields[1]
                break
            end
        end

        if test -z "$session_id"
            tmux new-session -d -s "$session_name" -n "$window_name" -c "$selected"
            for line in (tmux list-sessions -F "#{session_id}|#{session_name}" 2>/dev/null)
                set -l session_fields (string split --max 1 '|' -- $line)
                if test "$session_fields[2]" = "$session_name"
                    set session_id $session_fields[1]
                    break
                end
            end

            for line in (tmux list-windows -t "$session_id" -F "#{window_id}" 2>/dev/null)
                tmux set-option -w -t "$line" @ghq_path "$selected"
                break
            end
        end

        set -l window_id
        for line in (tmux list-windows -t "$session_id" -F "#{window_id}|#{@ghq_path}" 2>/dev/null)
            set -l window_fields (string split --max 1 '|' -- $line)
            if test "$window_fields[2]" = "$selected"
                set window_id $window_fields[1]
                break
            end
        end

        if test -z "$window_id"
            set window_id (tmux new-window -d -P -F "#{window_id}" -t "$session_id" -n "$window_name" -c "$selected")
            tmux set-option -w -t "$window_id" @ghq_path "$selected"
        end

        if set -q TMUX
            tmux switch-client -t "$session_id"
            tmux select-window -t "$window_id"
        else
            tmux select-window -t "$window_id"
            tmux attach-session -t "$session_id"
        end
    end
    commandline -f repaint
end
