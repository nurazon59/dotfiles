#!/bin/bash

echo "Dockにアプリケーションを追加中..."

# dockutilがインストールされているか確認
if ! command -v dockutil &> /dev/null; then
    echo "dockutilをインストールしています..."
    brew install dockutil
fi

# 現在のDockをクリア（オプション）
# dockutil --remove all

# よく使うアプリケーションを追加
# 以下は例です。必要に応じて変更してください
apps=(
    "/System/Applications/Finder.app"
    "/Applications/Safari.app"
    "/Applications/Google Chrome.app"
    "/Applications/Visual Studio Code.app"
    "/System/Applications/System Settings.app"
    "/Applications/Slack.app"
    "/Applications/Discord.app"
    "/Applications/Arc.app"
    "/Applications/WhatsApp.app"
)

for app in "${apps[@]}"; do
    if [ -e "$app" ]; then
        app_name=$(basename "$app" .app)
        echo "  -> $app_name を追加中..."
        dockutil --add "$app" --no-restart 2>/dev/null || echo "    (既に存在するか、追加できませんでした)"
    fi
done

# Dockを再起動
killall Dock

echo "Dockの設定が完了しました！"