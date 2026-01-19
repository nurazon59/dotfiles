function docker --wraps=docker --description 'Docker CLI with lazy completion loading'
    functions --erase docker
    docker completion fish | source
    command docker $argv
end
