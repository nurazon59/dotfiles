function ghq_fzf
    set -l ghq_root (ghq root)
    set -l entries

    # ghq repos
    for p in (ghq list -p)
        set -a entries $p\t(string replace "$ghq_root/" "" $p)
    end

    # worktrees (.wt directories under ghq repos)
    for wt_dir in (find $ghq_root -maxdepth 4 -name '.wt' -type d 2>/dev/null)
        set -l repo_dir (string replace "/.wt" "" $wt_dir)
        set -l repo_name (string replace "$ghq_root/" "" $repo_dir)
        for git_entry in (find $wt_dir -maxdepth 3 -name '.git' 2>/dev/null)
            set -l wt_path (dirname $git_entry)
            set -l rel (string replace "$wt_dir/" "" $wt_path)
            set -a entries $wt_path\t$repo_name:$rel
        end
    end

    set -l selected (printf '%s\n' $entries | fzf --height 40% --reverse --delimiter=\t --with-nth=2 | cut -f1)
    if test -n "$selected"
        cd $selected
    end
    commandline -f repaint
end
