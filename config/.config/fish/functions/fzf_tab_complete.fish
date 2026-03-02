function fzf_tab_complete
    set -l current_token (commandline -ct)
    set -l tokens (commandline -xpc)

    if test (count $tokens) -le 1; and test "$current_token" = "$tokens[1]"
        commandline -f complete
        return
    end

    if test -n "$tokens[1]"; and not type -q -- $tokens[1]
        return
    end

    fzf-completion
end
