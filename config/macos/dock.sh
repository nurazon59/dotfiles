#!/bin/bash

echo "Dock設定を適用中..."

# 自動的に隠す
defaults write com.apple.dock autohide -bool true

# 表示位置（left, bottom, right）
defaults write com.apple.dock orientation -string "left"

# アイコンサイズ
defaults write com.apple.dock tilesize -int 48

# 拡大機能を無効化
defaults write com.apple.dock magnification -bool false

# 最近使ったアプリケーションを表示しない
defaults write com.apple.dock show-recents -bool false

# 起動中のアプリケーションのみ表示
defaults write com.apple.dock static-only -bool false

# アニメーション速度を速くする
defaults write com.apple.dock autohide-delay -float 0.0
defaults write com.apple.dock autohide-time-modifier -float 0.15

# ゴミ箱を空にした時の警告を無効化
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Dockの再起動
killall Dock
