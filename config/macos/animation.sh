#!/bin/bash

echo "アニメーション高速化設定を適用中..."

# ウィンドウのリサイズアニメーションを高速化
defaults write -g NSWindowResizeTime -float 0.001

# Quick Lookウィンドウのアニメーション時間を0に
defaults write -g QLPanelAnimationDuration -float 0

# Dockの表示/非表示アニメーション高速化（既存の設定と統合）
defaults write com.apple.dock autohide-time-modifier -float 0.15
defaults write com.apple.dock autohide-delay -float 0

# Mission Controlのアニメーション高速化
defaults write com.apple.dock expose-animation-duration -float 0.1

# Finderとdockを再起動
killall Finder
killall Dock
