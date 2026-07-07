function __fzf_git_branch_complete --description 'List git branches for fzf, sorted by committerdate'
    set -l locals (command git for-each-ref --format='%(refname:short)' refs/heads/ 2>/dev/null)

    # 他worktreeでcheckout中のブランチを収集（現在のworktree自身は除外）
    set -l current_worktree (command git rev-parse --show-toplevel 2>/dev/null)
    set -l wt_branches
    set -l wt_path
    for line in (command git worktree list --porcelain 2>/dev/null)
        switch $line
            case 'worktree *'
                set wt_path (string sub -s 10 -- $line)
            case 'branch *'
                set -l br (string replace -r '^branch refs/heads/' '' -- $line)
                if test -n "$wt_path"; and test "$wt_path" != "$current_worktree"
                    set -a wt_branches $br
                end
        end
    end

    command git for-each-ref --sort=-committerdate \
        --format='%(refname:short)%09%(refname:short) %(if)%(upstream:short)%(then)→ %(upstream:short)%(else)(no upstream)%(end)  %(committerdate:relative)' \
        refs/heads/ 2>/dev/null | while read -l line
        set -l parts (string split -m1 \t -- $line)
        set -l tag '[L]'
        contains -- $parts[1] $wt_branches; and set tag '[L][W]'
        printf '%s\t%s %s\n' $parts[1] $tag $parts[2]
    end

    # symref (origin/HEAD 等) は除外。ローカル未作成のリモートは bare 名も候補化
    command git for-each-ref --sort=-committerdate \
        --format='%(symref)%09%(refname:short)%09%(committerdate:relative)' \
        refs/remotes/ 2>/dev/null | while read -l line
        set -l parts (string split \t -- $line)
        test -n "$parts[1]"; and continue
        set -l ref $parts[2]
        set -l date $parts[3]
        set -l bare (string replace -r '^[^/]+/' '' -- $ref)
        if not contains -- $bare $locals
            set -l tag '[R]'
            contains -- $bare $wt_branches; and set tag '[R][W]'
            printf '%s\t%s %s  %s\n' $bare $tag $ref $date
        end
        printf '%s\t[R] %s  %s\n' $ref $ref $date
    end
end
