function __git_head_branch --description 'Read current branch name from .git/HEAD without spawning git (fast for bulk repo listing)'
    set -l repo $argv[1]
    set -l git_dir $repo/.git

    if test -f $git_dir
        # worktree: .git is a file containing "gitdir: /path/to/actual/gitdir"
        read -l line <$git_dir
        set -l gd (string replace -r '^gitdir: ' '' -- $line)
        if string match -q '/*' -- $gd
            set git_dir $gd
        else
            set git_dir $repo/$gd
        end
    end

    set -l head_file $git_dir/HEAD
    test -f $head_file; or return 1

    read -l head_content <$head_file
    if string match -q 'ref: refs/heads/*' -- $head_content
        string replace -r '^ref: refs/heads/' '' -- $head_content
    else
        string sub -l 7 -- $head_content
    end
end
