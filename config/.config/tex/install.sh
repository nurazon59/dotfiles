#!/bin/bash

set -e

echo "TeXの設定をインストール中..."

# latexmkrcのシンボリックリンクを作成
if [ ! -e "$HOME/.latexmkrc" ]; then
    ln -s "$HOME/.config/tex/latexmkrc" "$HOME/.latexmkrc"
    echo "✓ .latexmkrcのシンボリックリンクを作成しました"
else
    echo "⚠ .latexmkrcは既に存在します"
fi

# TeXLiveのパッケージをインストール
if command -v tlmgr &> /dev/null; then
    echo "TeXパッケージをインストール中..."
    while IFS= read -r package; do
        if [ -n "$package" ]; then
            echo "  - $package をインストール..."
            sudo tlmgr install "$package" || echo "    ⚠ $package のインストールに失敗しました"
        fi
    done < "$HOME/.config/tex/tex-packages.txt"
    echo "✓ TeXパッケージのインストールが完了しました"
else
    echo "⚠ tlmgrが見つかりません。TeXLiveをインストールしてください"
fi

echo "TeXの設定が完了しました！"