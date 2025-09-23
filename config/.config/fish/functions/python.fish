function python
    if test "$argv[1]" = "-m" -a "$argv[2]" = "venv"
        echo "エラー: 'python -m venv'は禁止されています。代わりに'uv venv'を使用してください。"
        return 1
    else
        command python $argv
    end
end

function python3
    if test "$argv[1]" = "-m" -a "$argv[2]" = "venv"
        echo "エラー: 'python3 -m venv'は禁止されています。代わりに'uv venv'を使用してください。"
        return 1
    else
        command python3 $argv
    end
end