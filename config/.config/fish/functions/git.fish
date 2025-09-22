function git
    if test "$argv[1]" = "log"
        command git log --reverse $argv[2..-1]
    else
        command git $argv
    end
end