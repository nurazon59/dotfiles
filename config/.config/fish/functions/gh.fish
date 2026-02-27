function gh --wraps=gh --description 'GitHub CLI with ghmux sync'
    ghmux sync 2>/dev/null
    command gh $argv
end
