function __fzf_is_git_branch_context --description 'Detect git checkout/switch/branch -d context for fzf completion'
    set -l tokens $argv
    test (count $tokens) -ge 2; or return 1
    test $tokens[1] = git; or return 1
    # `git checkout -- path` などファイル指定なら除外
    contains -- -- $tokens; and return 1
    switch $tokens[2]
        case checkout switch rebase merge log show reset cherry-pick revert diff
            return 0
        case branch
            for t in $tokens[3..]
                switch $t
                    case -d -D --delete
                        return 0
                end
            end
    end
    return 1
end
