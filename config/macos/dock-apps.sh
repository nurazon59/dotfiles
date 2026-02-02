#!/bin/bash

echo "Dockの固定アプリを設定中..."

# dockutilが必要
if ! command -v dockutil &> /dev/null; then
    echo "dockutil がインストールされていません。brew install dockutil を実行してください。"
    exit 1
fi

# 現在のDockをクリア
dockutil --remove all --no-restart

# アプリを追加（左から順に）
dockutil --add "/System/Applications/Launchpad.app" --no-restart
dockutil --add "/System/Applications/System Settings.app" --no-restart
dockutil --add "/Applications/Alacritty.app" --no-restart
dockutil --add "/Applications/Arc.app" --no-restart
dockutil --add "/Applications/Discord.app" --no-restart
dockutil --add "/Applications/Slack.app" --no-restart
dockutil --add "/Applications/WhatsApp.app" --no-restart
dockutil --add "/Applications/Spotify.app" --no-restart
dockutil --add "/System/Applications/Preview.app" --no-restart
dockutil --add "/Applications/Aqua Voice.app" --no-restart

# Dockを再起動
killall Dock

echo "Dockの固定アプリを設定しました"
