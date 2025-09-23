function brew
    if test "$argv[1]" = "install"
        echo "エラー: 'brew install'は禁止されています。"
        echo "代わりに'brew bundle'を使用してください。"
        echo "Brewfileに追加してから'brew bundle'を実行してください。"
        return 1
    else
        command brew $argv
    end
end