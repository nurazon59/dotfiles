#!/bin/bash

echo "Control Center設定を適用中..."

# バッテリー表示
defaults write com.apple.controlcenter "NSStatusItem Visible Battery" -bool true

# WiFi表示
defaults write com.apple.controlcenter "NSStatusItem Visible WiFi" -bool true

# サウンド表示
defaults write com.apple.controlcenter "NSStatusItem Visible Sound" -bool true

# 再生中表示
defaults write com.apple.controlcenter "NSStatusItem Visible NowPlaying" -bool true

# 時計表示
defaults write com.apple.controlcenter "NSStatusItem Visible Clock" -bool true

# ディスプレイ非表示
defaults write com.apple.controlcenter "NSStatusItem Visible Display" -bool false

# 集中モード非表示
defaults write com.apple.controlcenter "NSStatusItem Visible FocusModes" -bool false

# 画面ミラーリング非表示
defaults write com.apple.controlcenter "NSStatusItem Visible ScreenMirroring" -bool false
