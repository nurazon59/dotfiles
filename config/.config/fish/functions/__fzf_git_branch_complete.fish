function __fzf_git_branch_complete --description 'List git branches for fzf, sorted by committerdate'
    set -l locals (command git for-each-ref --format='%(refname:short)' refs/heads/ 2>/dev/null)

    command git for-each-ref --sort=-committerdate \
        --format='%(refname:short)%09[L] %(refname:short) %(if)%(upstream:short)%(then)→ %(upstream:short)%(else)(no upstream)%(end)  %(committerdate:relative)' \
        refs/heads/ 2>/dev/null

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
            printf '%s\t[R] %s  %s\n' $bare $ref $date
        end
        printf '%s\t[R] %s  %s\n' $ref $ref $date
    end
end
