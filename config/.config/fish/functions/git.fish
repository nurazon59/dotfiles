function git --wraps=git --description 'git wrapper with ghmux sync on remote operations'
    if test (count $argv) -ge 1
        switch $argv[1]
            case push pull fetch clone remote
                ghmux sync 2>/dev/null
        end
    end

    command git $argv
end
