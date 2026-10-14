function __fish_aws_complete
    command -sq aws_completer; or return

    set -lx COMP_LINE (commandline -pc)
    set -lx COMP_POINT (string length -- $COMP_LINE)

    aws_completer | string replace -r ' $' ''
end

complete -c aws -f -a '(__fish_aws_complete)'
