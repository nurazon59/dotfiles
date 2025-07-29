#!/bin/bash

echo "Dock設定を適用中..."

# 表示位置（left, bottom, right）
defaults write com.apple.dock orientation -string "left"

# アイコンサイズ
defaults write com.apple.dock tilesize -int 48

# 拡大機能を無効化
defaults write com.apple.dock magnification -bool false

# アニメーション速度を速くする
defaults write com.apple.dock autohide-delay -float 0.0
defaults write com.apple.dock autohide-time-modifier -float 0.5

# ゴミ箱を空にした時の警告を無効化
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Dockの再起動
killall Dock
