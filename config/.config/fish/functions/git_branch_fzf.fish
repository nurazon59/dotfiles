function git_branch_fzf
    command git rev-parse --is-inside-work-tree >/dev/null 2>&1; or return

    set -l ghq_root (ghq root)
    set -l git_common_dir (command git rev-parse --path-format=absolute --git-common-dir)
    set -l main_worktree (string replace -r '/\.git$' '' -- $git_common_dir)
    set -l repo_name (string replace "$ghq_root/" "" $main_worktree)
    set -l session_name (string replace -r '^github\.com/' '' -- $repo_name)

    set -l locals (command git for-each-ref --format='%(refname:short)' refs/heads/ 2>/dev/null)

    set -l wt_branches
    set -l wt_paths
    set -l wt_path
    for line in (command git worktree list --porcelain 2>/dev/null)
        switch $line
            case 'worktree *'
                set wt_path (string sub -s 10 -- $line)
            case 'branch *'
                set -l br (string replace -r '^branch refs/heads/' '' -- $line)
                set -a wt_branches $br
                set -a wt_paths $wt_path
        end
    end

    set -l entries

    for line in (command git for-each-ref --sort=-committerdate --format='%(refname:short)%09%(committerdate:relative)' refs/heads/ 2>/dev/null)
        set -l parts (string split \t -- $line)
        set -l branch $parts[1]
        set -l date $parts[2]
        set -l path ''
        set -l display "$branch  $date"
        set -l wt_index (contains -i -- $branch $wt_branches)
        if test -n "$wt_index"
            set path $wt_paths[$wt_index]
            set display "$display  [worktree] $path"
        end
        set -a entries $branch\t$display\t$path
    end

    for line in (command git for-each-ref --sort=-committerdate --format='%(symref)%09%(refname:short)%09%(committerdate:relative)' refs/remotes/ 2>/dev/null)
        set -l parts (string split \t -- $line)
        test -n "$parts[1]"; and continue
        set -l ref $parts[2]
        set -l date $parts[3]
        set -l bare (string replace -r '^[^/]+/' '' -- $ref)
        contains -- $bare $locals; and continue
        set -l path ''
        set -l display "$bare  $date  ($ref)"
        set -l wt_index (contains -i -- $bare $wt_branches)
        if test -n "$wt_index"
            set path $wt_paths[$wt_index]
            set display "$display  [worktree] $path"
        end
        set -a entries $bare\t$display\t$path
    end

    set -l selected_line (printf '%s\n' $entries | fzf --height 40% --reverse --delimiter=\t --with-nth=2)
    if test -n "$selected_line"
        set -l selected_fields (string split \t -- $selected_line)
        set -l branch $selected_fields[1]
        set -l path $selected_fields[3]
        if test -n "$path"
            __ghq_tmux_open "$path" "$session_name" "$branch"
        else
            command git checkout "$branch"
        end
    end
    commandline -f repaint
end
