function ghq_fzf
    set -l repo (ghq list | fzf --height 40% --reverse)
    if test -n "$repo"
        cd (ghq root)/$repo
    end
    commandline -f repaint
end
