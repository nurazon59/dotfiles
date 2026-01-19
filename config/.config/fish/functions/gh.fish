function gh --wraps=gh --description 'GitHub CLI with lazy completion loading'
    functions --erase gh
    gh completion -s fish | source
    command gh $argv
end
