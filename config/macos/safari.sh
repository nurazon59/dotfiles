#!/bin/bash

echo "Safari設定を適用中..."

# 開発メニューを表示
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

# ステータスバーを表示
defaults write com.apple.Safari ShowStatusBar -bool true

# アドレスバーに完全なURLを表示
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

# デフォルトの検索エンジン（Google: 0, Yahoo: 1, Bing: 2, DuckDuckGo: 3）
defaults write com.apple.Safari SearchProviderIdentifier -string "com.google"

# ファビコンを表示
defaults write com.apple.Safari ShowIconsInTabs -bool true

# 自動的にダウンロードファイルを開かない
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# トラッキング防止
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

# プラグインを無効化
defaults write com.apple.Safari WebKitPluginsEnabled -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2PluginsEnabled -bool false

# Javaを無効化
defaults write com.apple.Safari WebKitJavaEnabled -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled -bool false
