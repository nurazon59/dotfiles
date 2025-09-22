function find
    # 引数がない場合は fd をそのまま実行
    if test (count $argv) -eq 0
        command fd
        return
    end

    # -name を使った検索を fd にマッピング
    if test "$argv[1]" = "-name" -a -n "$argv[2]"
        set pattern "$argv[2]"
        set -e argv[1..2]
        command fd "$pattern" $argv
        return
    end

    # -type f / -type d を fd にマッピング
    if test "$argv[1]" = "-type" -a "$argv[2]" = "f"
        set -e argv[1..2]
        command fd -t f $argv
        return
    else if test "$argv[1]" = "-type" -a "$argv[2]" = "d"
        set -e argv[1..2]
        command fd -t d $argv
        return
    end

    # それ以外はオリジナル find を実行
    command find $argv
end