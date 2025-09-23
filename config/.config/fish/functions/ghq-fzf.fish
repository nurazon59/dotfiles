function ghq-fzf
    set src (ghq list | fzf --preview "bat --color=always --style=header,grid --line-range :80 (ghq root)/{}/README.*" --bind="tab:down,btab:up")
    if test -n "$src"
        cd (ghq root)/$src
        commandline -f repaint
    end
end