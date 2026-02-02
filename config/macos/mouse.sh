#!/bin/bash

echo "マウス設定を適用中..."

# マウス速度
defaults write -g com.apple.mouse.scaling -float 3

# スクロールホイール速度
defaults write -g com.apple.scrollwheel.scaling -float 1.7

# ダブルクリック閾値
defaults write -g com.apple.mouse.doubleClickThreshold -float 5

# Force Click無効
defaults write -g com.apple.trackpad.forceClick -bool false
