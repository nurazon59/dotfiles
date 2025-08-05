#!/bin/bash

echo "Dock設定を適用中..."

# 表示位置（left, bottom, right）
defaults write com.apple.dock orientation -string "left"

# アイコンサイズ
defaults write com.apple.dock tilesize -int 48

# 拡大機能を無効化
defaults write com.apple.dock magnification -bool false

# アニメーション速度を調整（中速）
defaults write com.apple.dock autohide-delay -float 0.2
defaults write com.apple.dock autohide-time-modifier -float 0.8

# ゴミ箱を空にした時の警告を無効化
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Dockの構成を設定（固定アプリ｜開いているアプリ｜ゴミ箱）
# 最近使ったアプリケーションをDockに表示する
defaults write com.apple.dock show-recents -bool true

# 起動中のアプリケーションをDockに表示
defaults write com.apple.dock static-only -bool false

# アプリケーションを開いたままDockから削除可能にする
defaults write com.apple.dock show-process-indicators -bool true

# Dockの自動非表示を有効化
defaults write com.apple.dock autohide -bool true

# Dockの再起動
killall Dock
