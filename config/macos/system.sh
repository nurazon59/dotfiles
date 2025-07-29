#!/bin/bash

echo "システム全体の設定を適用中..."

# ダークモードを有効化
defaults write -g AppleInterfaceStyle -string "Dark"

# 言語設定
defaults write -g AppleLanguages -array "ja-JP"
defaults write -g AppleLocale -string "ja_JP"

# ダブルクリックでウィンドウを最小化しない
defaults write -g AppleMiniaturizeOnDoubleClick -bool false

# アンチエイリアシング
defaults write -g AppleAntiAliasingThreshold -int 4

# スクロールバーの表示設定
defaults write -g AppleShowScrollBars -string "Automatic"

# メニューバーの透明度
defaults write -g AppleEnableMenuBarTransparency -bool true

# アプリケーション終了時の確認ダイアログを無効化
defaults write -g NSDisableAutomaticTermination -bool true

# クラッシュレポーターを無効化（開発者向け）
defaults write com.apple.CrashReporter DialogType -string "none"

# 起動音を無効化
sudo nvram SystemAudioVolume=" " 2>/dev/null || true
