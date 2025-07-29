#!/bin/bash

echo "スクリーンショット設定を適用中..."

# 保存先をデスクトップからダウンロードフォルダに変更
mkdir -p ~/Downloads/Screenshots
defaults write com.apple.screencapture location -string "${HOME}/Downloads/Screenshots"

# ファイル名のプレフィックスを設定
defaults write com.apple.screencapture name -string "Screenshot"

# 影を含めない
defaults write com.apple.screencapture disable-shadow -bool true

# 保存形式をPNGに設定（他のオプション: BMP, GIF, JPG, PDF, TIFF）
defaults write com.apple.screencapture type -string "png"

# スクリーンショット後にサムネイルを表示しない
defaults write com.apple.screencapture show-thumbnail -bool false

# SystemUIServerを再起動して設定を反映
killall SystemUIServer
