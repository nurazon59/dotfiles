function wt
    if test -z "$argv[1]"
        echo "Usage: wt <branch-name>"
        return 1
    end

    # nurazon59/プレフィックスを追加（すでに付いている場合は重複しない）
    if string match -q "nurazon59/*" "$argv[1]"
        set branch "$argv[1]"
    else
        set branch "nurazon59/$argv[1]"
    end
    
    set dir "../"(string replace -a "/" "-" "$branch")

    # すでに存在するブランチか確認
    if not git show-ref --quiet "refs/heads/$branch"
        git branch "$branch"
    end

    git worktree add "$dir" "$branch"
end