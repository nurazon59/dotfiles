function ghq_fzf
    set -l ghq_root (ghq root)
    set -l entries

    # ghq repos
    for p in (ghq list -p)
        set -a entries $p\t(string replace "$ghq_root/" "" $p)
    end

    # worktrees (git wt経由で取得、スラッシュ入りブランチにも対応)
    for repo in (ghq list -p)
        test -d "$repo/.wt"; or continue
        set -l repo_name (string replace "$ghq_root/" "" $repo)
        for wt_line in (git -C $repo worktree list --porcelain 2>/dev/null | string match 'worktree *')
            set -l wt_path (string replace 'worktree ' '' $wt_line)
            # メインworktreeはghq listで既に含まれるのでスキップ
            test "$wt_path" = "$repo"; and continue
            set -l rel (string replace "$repo/.wt/" "" $wt_path)
            set -a entries $wt_path\t$repo_name:$rel
        end
    end

    set -l selected (printf '%s\n' $entries | fzf --height 40% --reverse --delimiter=\t --with-nth=2 | cut -f1)
    if test -n "$selected"
        cd $selected
    end
    commandline -f repaint
end
